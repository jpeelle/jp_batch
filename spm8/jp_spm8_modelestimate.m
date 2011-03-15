function S = jp_spm8_modelestimate(S, subnum)
%JP_SPM8_MODELESTIMATE Run first-level model with SPM5.
%
% S = JP_SPM8_MODELESTIMATE(S, SUBNUM) runs a first level analysis on the
% specified subject number SUBNUM from an S structure (see
% JP_INIT). The model is set up using JP_SPM8_MODELDESIGN.
%
% See JP_DEFAULTS_SPMFMRI for a full list of defaults.
%
% You should make sure to review your design at some point to make sure it
% looks reasonable.
%
% See SPM_FMRI_DESIGN and SPM_SPM for the structure of the SPM
% struct.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);


% log files
[alllog, errorlog, estimatelog] = jp_createlogs(subname, S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);


if isempty(cfg.statsdir)
  jp_log(estimatelog, 'Must specify stats directory!', 2);
end

% Keep track of original working directory so we can get back here.
originalDir = pwd;


jp_log(estimatelog, 'Running JP_SPM8_MODELESTIMATE...\n');


% Run the model for all sessions (normal) or for one session at a
% time (rare)
if cfg.separatesessions==0
  estimatemodel(S, subnum, 1:length(S.subjects(subnum).sessions));  
else
  for s=1:length(S.subjects(subnum).sessions)
    estimatemodel(S, subnum, s);
  end  
end % separatesession check


% Go back to wherever we were
cd(originalDir);

end % main function



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function estimatemodel(S, subnum, sessionnum)


% log files
[alllog, errorlog, estimatelog] = jp_createlogs(S.subjects(subnum).name, S.subjdir, mfilename);

cfg = S.cfg.jp_spm8_modelestimate;

subjdir = S.subjdir;
thissub = S.subjects(subnum).name;

savepath = fullfile(cfg.statsdir, thissub);
if cfg.separatesessions > 0
  savepath = [savepath '_' S.subjects(subnum).sessions(sessionnum).name];
end
  
if ~isdir(savepath)
  jp_log(errorlog, sprintf('Stats directory %s does not exist.', savepath));
end

cd(savepath);

load SPM

% Estimate parameters.
jp_log(estimatelog,'Estimating parameters...\n');
spm_spm(SPM);
jp_log(estimatelog,'Done estimating parameters.\n');


if cfg.savemask > 0
  jp_log(estimatelog, 'You requested the mask.img to be saved as an image file, but this is temporarily disabled.\n');
  %   spm_figure('clear');
  %   spm_orthviews('image', fullfile(savepath, 'mask.img'));
  %   job.fname = fullfile(savepath, 'mask.png');
  %   job.opts.opt = {'-dpng', '-r200'};
  %   spm_print(job);
end

end % estimatemodel subfunction

    
