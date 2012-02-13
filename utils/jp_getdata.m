function Y = jp_getdata(roi, imgs, cfg)
%JP_GETDATA Extract data from an ROI or XYZ coordinate (mm).
%
% JP_GETDATA(ROI, IMAGES) extracts the data from >0 voxels in ROI (an
% image) from the list of images in IMAGES, all assumed to be voxelwise
% aligned and in the same space. If either ROI or IMAGES are not specified,
% they can be selected.
%
% JP_GETDATA(XYZ, IMAGES) works the same way, but uses an n-by-3 list of
% XYZ coordinates (mm) as locations.
%
% JP_GETDATA(ROI, IMAGES, OPTIONS) allows you to specify a few
% options:
%
%   options.summarize   0 or 'raw' - don't summarize data
%                       'mean'     - mean across voxels for each image
%                       'median'   - median across voxels for each image
%
% If not specified, data will be averaged across voxels (note that if
% specifying XYZ coordinates directly, you will probably want to change
% this).
%
% JP_GETDATA depends on some helper functions from recent versions
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


% Get the space of the first image, which we'll use for either the ROI or
% XYZ-based method.
Vimg = spm_vol(imgs);
Vinv = inv(Vimg(1).mat);


% If the user passed one or more images, assume ROI image. Otherwise try
% to use XYZ coordinates.

if ischar(roi) || iscell(roi)
  % get the roi data
  Vroi = spm_vol(roi);
  [Yroi,XYZroi] = spm_read_vols(Vroi);

  % find the coordinates we want (i.e. > 0)
  XYZmm = XYZroi(:,Yroi>0);

  % convert XYZmm to XYZvoxel
  %  Minv  = inv(V(1).mat);
  %  XYZ   = Minv(1:3,1:3)*XYZm + repmat(Minv(1:3,4),1,size(XYZm,2));

  %Vinv = inv(Vroi(1).mat);
  XYZvoxel = Vinv(1:3,1:3)*XYZmm + repmat(Vinv(1:3,4),1,size(XYZmm,2));

else
  % assume XYZ coordinates were provided by user

  % if not already, turn them into 3-by-n list, unless 3x3
  if size(roi,2)==3
    if size(roi,1)==3
      fprintf('Warning: You provided a 3x3 matrix. Assuming each row is a coordinate (i.e. n x 3 list).\n');
    end

    roi = roi'; % flip
  end

  XYZvoxel = Vinv(1:3,1:3)*roi + repmat(Vinv(1:3,4),1,size(roi,2));

end

% extract data using nearest neighbor interpolation
Y = spm_get_data(Vimg, XYZvoxel, 1);

% summarize if necessary
if strcmp(cfg.summarize, 'mean')
  Y = mean(Y,2);
elseif strcmp(cfg.summarize, 'median')
  Y = median(Y,2);
end

