% Everything needed to run an analysis (or to see what has been run in a
% previous analysis) for a given study is found in the S structure, which
% is usually saved to S.mat in the main study folder. This should easily
% let you add subjects or stages to a study, or see what has been run, at
% any time. If you pass a properly-formatted S structure to JP_RUN, all
% stages and subjects will be run (unless they have been run previously,
% etc.).
%
% Because everything for your analysis is contained in the S structure, so
% you need to keep track of it.  Note that many functions will return an
% updated S structure; for example, S = jp_init(S) is correct; simply
% running jp_init(S) with no output won't work.
%
% The minimal fields you need in S are the subject directory, some analysis
% stages to run, and some subjects to run.
%
% The cfg field (S.cfg) contains all options for determining how the
% analysis is done, and all configurable options for any processing stage.
% See JP_DEFAULTS_SPMFMRI for all available options.
%
% See JP_BATCH and JP_SPM_SETUP for more.

% Jonathan Peelle



%% add necessary paths (unless you add these somehwere else)
%  Because the various functions live in subfolders, you need to either (a)
%  add those to your Matlab path, or (b) run the following command, which
%  adds all subfolders. This assumes the main jp_batch directory is in your
%  path.

jp_batch('addpaths');



%% Start with a clean S structure, and a blank .cfg field

S = [];
S.cfg = [];



%% Set up the directory and subject information 
S.subjdir = '/imaging/jp01/experiments/attention_sylvia/subj';  % this is where subject folders are



%% Add subjects
S = jp_addsubject(S, 'CBU090902');
S = jp_addsubject(S, 'CBU090903');



%% Specify the stages of analysis we want to run

S = jp_addanalysis(S, 'jp_spm8_movefirstscans');
S = jp_addanalysis(S, 'jp_spm8_tsdiffana');
S = jp_addanalysis(S, 'jp_spm8_realign');
S = jp_addanalysis(S, 'jp_spm8_coregister');
S = jp_addanalysis(S, 'jp_spm8_coregisterstructural2template');
S = jp_addanalysis(S, 'jp_spm8_segment');
S = jp_addanalysis(S, 'jp_spm8_normalize');
S = jp_addanalysis(S, 'jp_spm8_normalizestructural');
S = jp_addanalysis(S, 'jp_spm8_smooth');
S = jp_addanalysis(S, 'jp_makereport');      % makes the jp_report.html page


% After you have collected all your subjects, you may want to add the following,
% useful for displaying and localizing results:
% S = jp_addanalysis(S, 'jp_spm8_createmeanstructural', 'study');


% If you want to identify scans that exceed some threshold for movement
% or intensity difference, use jp_spm8_viewbadscans to get a sense of 
% parameters, and then:
% S = jp_addanalysis(S, 'jp_spm8_getbadscans') % any time after tsdiffana


%% This is required to be run to set defaults for all the analyses
S = jp_init(S);


%% Add any other options for this analysis (or override defaults...)
S.cfg.jp_spm8_movefirstscans.numscans = 4;
S.cfg.jp_spm8_normalize.prefix = '';
S.cfg.jp_spm8_smooth.prefix = 'w';    % this tells smooth to only select the normalized (w*) images
S.cfg.jp_spm8_smooth.fwhm = 10;       % this is how much we are smoothing for



%% Now, run the analysis!
S = jp_run(S);



% (After running, you may want to save S again to keep a record of the
% values used. By default S.cfg.options.saveS is set to 1, which will
% automatically save S in the folder containing S.subjdir everytime you run
% JP_RUN; this is the default.  The record of analyses kept in S will be
% more complete if you load S to run it instead of creating it from a blank
% structure each time, but it's probably not a big deal.)

