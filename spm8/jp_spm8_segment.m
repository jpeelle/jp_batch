function S = jp_spm8_segment(S, subnum)
%JP_SPM8_SEGMENT Segment structural images using SPM8.
%
% S = JP_SPM8_SEGMENT(S, subnum)
%
% S.cfg.jp_spm8_segment contains options including:
%  biascorrectfirst  0 to turn off additional bias-correction (see below) (default 1)
%
% Sometimes the normal SPM segmentation fails due to image
% inhomogeneity (for example, using a multi-channel head coil).
% The two stage segmentation process first writes out an
% bias-corrected image, and then performs segmentation on
% this image.  The bias-corrected image has an 'm'
% prepended to the file name.
%
% You may want to  manually reorient the images to
% ensure that the origin (0,0,0) is reasonably close to the
% anterior commisure before segmentation.
%
% For an alternative interface to segmentation that doesn't
% automatically select an image, see JP_SPM_SEGMENTIMAGE.
%
%
% See JP_DEFAULTS for a full list and defaults.

% Jonathan Peelle
% University of Pennsylvania

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);

subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

try
  structprefix = S.subjects(subnum).structprefix;
catch
  structprefix = jp_getinfo('structprefix', S.subjdir, subname);
end

try
  structdirs = S.subjects(subnum).structdirs;
catch
  structdirs = jp_getinfo('structdirs', S.subjdir, subname);
end


% log files
[alllog, errorlog, segmentlog] = jp_createlogs(subname, S.subjdir, mfilename);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get file from first structural directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jp_log(segmentlog, 'Looking for structural image...\n', 1);
structimage = jp_getstructimages(structprefix, S.subjdir, subname, structdirs(1), S.cfg.options.mriext);

if size(structimage,1) > 1
  disp(structimage)
  structimage = structimage(1,:);
  jp_log(segmentlog, sprintf('Warning, more than 1 structural image found, using first: %s.\n', structimage), 1);
end
  
if isempty(structimage) || strcmp(structimage, '/')
  error('No structural image found!');
end

jp_log(segmentlog, sprintf('Found %s.\n', structimage), 1);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Segment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jp_log(segmentlog, 'Segmenting image...\n', 1);
jp_spm8_segmentimage(structimage, cfg);
jp_log(segmentlog, 'done.\n');





