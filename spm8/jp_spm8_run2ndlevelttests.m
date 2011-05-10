function S = jp_spm8_run2ndlevelttests(S)
%JP_SPM8_RUN2NDLEVELTTESTS Runs 2nd level t contrasts.
%
% S = JP_SPM8_RUN2NDLEVELTTESTS(S) runs 2nd level t contrasts that have
% been previously specified. Because this is for 2nd level analyses, all
% subjects in the S structure must have these contrasts already specified
% and run (using JP_SPM8_CONTRASTS).
%
% This must be run on the study level; i.e.:
%
%  S = jp_addanalysis(S, 'jp_spm8_run2ndlevelttests', 'study')
%
% The contrasts are loaded in from the SPM.mat file from the first subject,
% and assumed to be identical for all subjects.
%
% See JP_DEFAULTS_SPMFMRI for a full list of defaults.

% Jonathan Peelle
% University of Pennsylvania


% log files
[alllog, errorlog, tlog] = jp_createlogs('', S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);


% load in the SPM.mat from the first subject
load(fullfile(cfg.statsdir, S.subjects(1).name, 'SPM.mat'));

% if no contrasts specified, figure out the T contrasts
if isempty(cfg.which_contrasts)
  cfg.which_contrasts = find(strcmp({SPM.xCon.STAT}, 'T'));
end

for w = 1:length(cfg.which_contrasts);
  thisc = cfg.which_contrasts(w);
  jp_log(tlog, 'Running contrast %i...\n');
  
  if ~strcmp(SPM.xCon(thisc).STAT, 'T')
    jplog(tlog, 'WARNING: Contrast %i (%s) is not a T contrast.\n', thisc, SPM.xCon(thisc).name);
  else
    % get images
    
    
    % configure rest of the design matrix
    
    
    
    % run the model (redo jp_rik_2ndlevel)
    
    
    
  end  % checking for t contrasts
end % running through contrasts


  
  
  
  