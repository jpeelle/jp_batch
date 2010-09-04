function cfg = jp_defaults_general(cfg)
%JP_DEFAULTS_GENERAL Default values for all JP_BATCH functions.

% If no exisiting cfg, make a blank one
if nargin < 1
  cfg = struct();
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg.options.checkforerrors = 1;         % don't run a stage if errors happened before
cfg.options.checkfordone   = 1;         % don't run a stage if previously completed
cfg.options.startspm       = 0;         % avoid GUI errors by starting SPM at outset (SPM8)
cfg.options.analysisname   = '';        % appended to 'done' flags to allow multiple analyses
cfg.options.chmodgrw       = 0;         % at the end try to make everything group read/writeable (linux only)


% filetype
cfg.options.mriext = 'nii';             % 'nii' or 'img'


% (these ones are less used)
cfg.options.modality       = {'fMRI'};  % possibly used in the future
cfg.options.runstages      = 1;         % set to 0 to test out which stages would be run
cfg.options.software       = {'SPM'};   % packages used in this analysis (not used)
cfg.options.spmver         = [];        % if set (e.g. 'SPM5') jp_run tries to make sure correct version is being run
cfg.options.saveS          = 1;         % save S before and after running
cfg.options.defsfunction = 'jp_defaults';


% only if you use AA (don't do it)
cfg.options.aapath         = '/imaging/jp01/software/aa/devel';
cfg.options.aacmd          = 'aa_ver301';
cfg.options.aadoneflags    = 0;         % make done flags aa will respect


% makereport
cfg.jp_makereport = [];
