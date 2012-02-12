function Y = jp_extractroidata(roi, imgs, cfg)
%JP_EXTRACTROIDATA Extract data from an ROI.
%
% JP_EXTRACTROIDATA(ROI, IMAGES) extracts the data from >0 voxels in ROI
% from the list of images in IMAGES, all assumed to be voxelwise aligned
% and in the same space. If either ROI or IMAGES are not specified, they
% can be selected.
%
% JP_EXTRACTROIDATA(ROI, IMAGES, OPTIONS) allows you to specify a few
% options:
%
%   options.summarize   0 or 'raw' - don't summarize data
%                       'mean'     - mean across voxels for each image
%                       'median'   - median across voxels for each image
%
% JP_EXTRACTROIDATA depends on some helper functions from recent versions
% of SPM.

% Jonathan Peelle
% University of Pennsylvania

if nargin < 3
  cfg = [];
end

if ~isfield(cfg, 'summarize') || isempty(cfg.summarize)
  cfg.summarize = 'mean';
end

if nargin < 1 || isempty(roi)
  roi = spm_select(1, 'Image', 'Select ROI to use for extraction');
end

if nargin < 2 || isempty(imgs)
  imgs = spm_select(Inf, 'Image', 'Select images from which to get data');
end


% get the roi data
Vroi = spm_vol(roi);
[Yroi,XYZroi] = spm_read_vols(Vroi);

% find the coordinates we want (i.e. > 0)
XYZmm = XYZroi(:,Yroi>0);

% convert XYZmm to XYZvoxel
%  Minv  = inv(V(1).mat);
%  XYZ   = Minv(1:3,1:3)*XYZm + repmat(Minv(1:3,4),1,size(XYZm,2));

Vinv = inv(Vroi(1).mat);
XYZvoxel = Vinv(1:3,1:3)*XYZmm + repmat(Vinv(1:3,4),1,size(XYZmm,2));


% extract data from real images
Y = spm_get_data(spm_vol(imgs), XYZvoxel, 1);

% summarize if necessary
if strcmp(cfg.summarize, 'mean')
  Y = mean(Y,2);
elseif strcmp(cfg.summarize, 'median')
  Y = median(Y,2);
end
