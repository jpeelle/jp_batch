function Y = jp_getdata(roi, imgs, cfg)
%JP_GETDATA Extract data from an ROI or XYZ coordinate (mm).
%
% Y = JP_GETDATA(ROI, IMAGES) extracts the data from >0 voxels in ROI (an
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
%   options.summarize   'raw'      - don't summarize data
%                       'mean'     - mean across voxels for each image
%                       'median'   - median across voxels for each image
%
% If not specified, data will be averaged across voxels (note that if
% specifying XYZ coordinates directly, you will probably want to change
% this).
%
% If you specify multiple XYZ coordinates and summarize, you will get a
% column with one value per image. If you do not summarize, you will get
% one row per image, with each column reflecting the value at that
% coordinate.
%
% If you specify multiple ROI images and summarize, you will get a column
% for every ROI, with a row for every image. If you do not summarize, each
% ROI will take up as many columns as voxels in the ROI.
%
% Using the above information can be helpful if you would like to extract
% data for multiple conditions to plot, say, results from an fMRI analysis.
% Knowing the order in which the data are returned, you can alter the
% output to make it easier to plot (e.g., using RESHAPE).
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

if ~ischar(cfg.summarize) || ~ismember(cfg.summarize, {'raw' 'mean' 'median'})
  error('OPTIONS.SUMMARIZE must be one of ''raw'', ''mean'', or ''median''.');
end

if nargin < 1 || isempty(roi)
  roi = spm_select(Inf, 'Image', 'Select ROI(s) to use for extraction');
end

if nargin < 2 || isempty(imgs)
  imgs = spm_select(Inf, 'Image', 'Select images from which to get data');
end

% Get the space of the first image, which we'll use for either the ROI or
% XYZ-based method. All images assumed to be in same space.
Vimg = spm_vol(imgs);
Vinv = inv(Vimg(1).mat);

% If the user passed one or more images, assume ROI image. Otherwise try
% to use XYZ coordinates.

if ischar(roi) || iscell(roi)

  Y = []; % for holding results - would be better to initialize to a size

  % loop through ROI images
  for i=1:size(roi,1)
    % get the roi data
    Vroi = spm_vol(roi(i,:));
    [Yroi,XYZroi] = spm_read_vols(Vroi); % XYZ returned in mm

    % find the coordinates we want (i.e. > 0)
    XYZmm = XYZroi(:,Yroi>0);

    % note how many voxels if this seems relevant for user (i.e. if not
    % summarizing, and more than one ROI)
    if size(roi,1)>1 && ismember(cfg.summarize, {'mean' 'median'})
      fprintf('ROI #%2i:\t %3i voxels\t%s\n', i, length(find(Yroi>0)), roi(i,:));
    end

    % convert XYZmm to XYZvoxel
    %  Minv  = inv(V(1).mat);
    %  XYZ   = Minv(1:3,1:3)*XYZm + repmat(Minv(1:3,4),1,size(XYZm,2));

    %Vinv = inv(Vroi(1).mat);
    XYZvoxel = Vinv(1:3,1:3)*XYZmm + repmat(Vinv(1:3,4),1,size(XYZmm,2));

    % extract data using nearest neighbor interpolation
    d = spm_get_data(Vimg, XYZvoxel, 1);

    % summarize if necessary
    if strcmp(cfg.summarize, 'mean')
      d = mean(d,2);
    elseif strcmp(cfg.summarize, 'median')
      d = median(d,2);
    end

    Y = [Y d];

  end
else
  % assume XYZ coordinates were provided by user

  % if not already, turn them into 3-by-n list, unless 3x3
  if size(roi,2)==3
    if size(roi,1)==3
      fprintf('Note: You provided a 3x3 matrix. Assuming each row is a coordinate (i.e. n x 3 list).\n');
    end

    roi = roi'; % flip
  end

  XYZvoxel = Vinv(1:3,1:3)*roi + repmat(Vinv(1:3,4),1,size(roi,2));

  % extract data using nearest neighbor interpolation
  Y = spm_get_data(Vimg, XYZvoxel, 1);

  % summarize if necessary
  if strcmp(cfg.summarize, 'mean')
    Y = mean(Y,2);
  elseif strcmp(cfg.summarize, 'median')
    Y = median(Y,2);
  end

end



