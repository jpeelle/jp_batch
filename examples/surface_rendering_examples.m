% The best way to get good results with this surface rendering script is to
% experiment a bit with the various options, which are listed if you type
% HELP JP_SPM8_SURFACERENDER (as long as it's in your Matlab path, see the
% first line below).
%
% What I usually do as a first step is to view Results in SPM and decide on
% results I'd like to display, then save those thresholded maps as a
% separate image (using the "save" button in SPM).  Then simply select this
% thresholded map to display, and you know exactly the statistics of the
% image being displayed.

% make sure jp_spm8_surfacerender is in your path
addpath /imaging/jp01/jp_batch/spm8


% select an image, e.g., whatever results you want to show
img = spm_select;

% (or you can specify the path yourself:)
% img = '/path/to/image.nii';

% set some options
cfg = [];
cfg.colorscale = [2 4]; % sometimes this needs to be played around with to make it look ok
cfg.inflate = 5;
cfg.plots = [1 2];  % or [1:4] for all views

jp_spm8_surfacerender(img, 'hot', cfg);



% Note that you can also easily specify a single color for the colormap,
% e.g., to show ROIs you might show them in white:
img = '/imaging/sw01/HammersROI/Hammers33_RInfParietal.img';
cfg.colorscale = [0 1];
jp_spm8_surfacerender(img, [1 1 1], cfg);

% For something continuous, like showing both positive and negative values
% on an unthresholded t map, use something like:
%cfg.colorscale = 'symmetrical';
%jp_spm8_surfacerender(img, 'jet', cfg);
