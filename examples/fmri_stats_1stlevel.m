% Running 1st level models with JP_BATCH scripts.
%
% Almost all of the options are set in the S structure; however, contrasts
% must be specified in a contrasts.m file that you create within the stats
% directory.  If you run JP_SPM_SETUP and specify that you are setting up a
% stats directory, an example contrasts file will be created for you.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



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


%% Add analysis stages

S = jp_addanalysis(S, 'jp_spm8_specify1stlevel');
S = jp_addanalysis(S, 'jp_spm8_modelestimate');
S = jp_addanalysis(S, 'jp_spm8_contrasts');


%% Initialize with defaults
S = jp_init(S);


%% Configure options
% Note the statsdir, where the output is saved, must be specified for each
% of the stages.  If you want to run multiple analyses on the same
% preprocessed data, just change this directory name. This directory needs
% to be created ahead of time, and contains the contrasts.m file needed for
% contrasts.

S.cfg.jp_spm8_specify1stlevel.statsdir = '/imaging/jp01/experiments/attention_sylvia/stats_removebadscans_andmotion';
S.cfg.jp_spm8_specify1stlevel.include_movement = 1;  % include 6 movement parameters in the model
S.cfg.jp_spm8_specify1stlevel.prefix = 'sw';         % look for sw* files

% other examples of things you could set:
%S.cfg.jp_spm8_specify1stlevel.include_badscans = 1; % those identified using jp_spm8_getbadscans
%S.cfg.jp_spm8_specify1stlevel.xM.VM = '/imaging/local/spm/spm8/apriori/brainmask.nii'; % explicit mask


% Each condition gets added like this; this name must match the name of the
% text files that contain the event onsets (ev_files).  See
% JP_SPM8_SPECIFY1STLEVEL for more on how to name these text files.
S.cfg.jp_spm8_specify1stlevel.conditions(1).name = 'scn';
S.cfg.jp_spm8_specify1stlevel.conditions(2).name = 'unambiguous';
S.cfg.jp_spm8_specify1stlevel.conditions(3).name = 'ambiguous';

% (set the stats directory to what we specified above for estimating and contrasts)
S.cfg.jp_spm8_modelestimate.statsdir = S.cfg.jp_spm8_specify1stlevel.statsdir;
S.cfg.jp_spm8_contrasts.statsdir = S.cfg.jp_spm8_specify1stlevel.statsdir;

% N.B. You will also need a contrasts.m file in the stats directory that will
% specify what contrasts you want run. If you run jp_spm_setup, you will get a
% blank contrasts.m file in the stats directory which you can modify.
% For more, see JP_SPM8_CONTRASTS.


%% Run the analysis
S = jp_run(S);



