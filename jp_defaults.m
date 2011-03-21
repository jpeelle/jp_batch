function cfg = jp_defaults()
%JP_DEFAULTS Set default values.
%
% Any file setting default values for an analysis is of the form: cfg =
% default_function();
%
% When you set up an S structure to be run, you can list the defaults
% function in S.cfg.options.defaultsfunction; if not set JP_DEFAULTS is
% called with the below settings. Look in each of those files (e.g.,
% jp_defaults_spmfmri) to see what defaults are used for each function.
%
% The built-in defaults functions live in the defaults folder, or you can
% make your own.

% Jonathan Peelle
% University of Pennsylvania


cfg = struct();
cfg = jp_defaults_general(cfg);
cfg = jp_defaults_spmfmri(cfg);

