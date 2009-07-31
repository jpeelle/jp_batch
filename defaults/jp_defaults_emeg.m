function cfg = jp_defaults_aa(cfg)
%JP_DEFAULTS_AA Default values for using AA scripts.

% If no exisiting cfg, make a blank one
if nargin < 1
  cfg = struct();
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AA options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg.aap.options.autoidentifyfieldmaps = 1;
cfg.aap.options.deletestructuralaftercopyingtocentralstore = 0;
cfg.aap.options.fieldmapundistortversion = 'fieldmap_undistort_v403';

