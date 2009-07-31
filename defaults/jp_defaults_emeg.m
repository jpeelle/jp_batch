function cfg = jp_defaults_emeg(cfg)
%JP_DEFAULTS_EMEG Default values for using E/MEG scripts.

% If no exisiting cfg, make a blank one
if nargin < 1
  cfg = struct();
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% jp_ft_getdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg.jp_ft_getdata.heog_label = 'EEG061';
cfg.jp_ft_getdata.veog_label = 'EEG062';
cfg.jp_ft_getdata.ecg_label = 'EEG063';

%cfg.jp_ft_getdata.analysisdir = [];

cfg.jp_ft_getdata.trialfile = 1; % if 1, txt file with trial times required

% set the following to define your own trials using fieldtrip
cfg.jp_ft_getdata.triggers = [];
cfg.jp_ft_getdata.prestim = [];
cfg.jp_ft_getdata.poststim = [];

cfg.jp_ft_getdata.veogreject = 0;
cfg.jp_ft_getdata.veogreject_cfg = [];
cfg.jp_ft_getdata.jumpreject = 0;
cfg.jp_ft_getdata.jumpreject_cfg = [];

% the preprocessing subfield gets passed in its entirety to
% FieldTrip's PREPROCESSING function as the cfg option
cfg.jp_ft_getdata.preprocessing.bpfilter = 'yes';
cfg.jp_ft_getdata.preprocessing.bpfreq = [0.1 30]
cfg.jp_ft_getdata.preprocessing.lpfilter = 'no'
cfg.jp_ft_getdata.preprocessing.hpfilter = 'no'
cfg.jp_ft_getdata.preprocessing.checkboundary = 0
cfg.jp_ft_getdata.preprocessing.continuous = 'yes'
cfg.jp_ft_getdata.preprocessing.channel = {'MEG'}
cfg.jp_ft_getdata.preprocessing.blc = 'yes'
