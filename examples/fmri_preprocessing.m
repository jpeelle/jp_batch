% Everything for your analysis is contained in the S structure, so you need
% to keep track of it.  Note that many functions will return an updated S
% structure; for example, S = jp_init(S) is correct; simply running
% jp_init(S) with no output won't work.
%
% The minimal fields you need in S are the subject directory, some analysis
% stages to run, and some subjects to run.
%
% The cfg field (S.cfg) contains all options for determining how the
% analysis is done, and all configurable options for any processing stage.
% See JP_DEFAULTS for all available options.
%
% JP_INIT fills in subject-specific values for sessions,
% directories, etc. based on info.* text files; see JP_BATCH and
% JP_SPM_SETUP for more.


%% add necessary paths (unless you add these somehwere else)
%  Because the various functions live in subfolders, you need to either (a)
%  add those to your Matlab path, or (b) run the following command, which
%  adds all subfolders.
jp_batch('addpaths');



%% Start with a clean S structure, and a blank .cfg field
S = [];
S.cfg = [];


%% Set up the stages for analysis.
%  Stage names correspond to function names
S.analysis(1).name = 'jp_spm8_realign';
S.analysis(2).name = 'jp_spm8_coregister';
S.analysis(3).name = 'jp_spm8_segment';
S.analysis(4).name = 'jp_spm8_normalize';
S.analysis(5).name = 'jp_spm8_smooth';



%% Set options

% required - the directory containing subject directories
S.subjdir = '/imaging/jp01/jp_spm_exampledata/quick_test_data/subj';

% the rest are only necessary where you want defaults changed

% (general options)
S.cfg.options.checkfordone = 1;  % only run stages that haven't been run before
S.cfg.options.saveS = 1;         % save S before and after running things
S.cfg.options.startspm = 1;      % needed to avoide GUI problems in SPM8 (at least for me)


% (now for SPM stages)
S.cfg.jp_spm8_realign.prefix = '';
S.cfg.jp_spm8_segment.biascorrectfirst = 1;
S.cfg.jp_spm8_normalize.prefix = '';
S.cfg.jp_spm8_smooth.prefix = 'w';
S.cfg.jp_spm8_smooth.fwhm = 10;  % fwhm is always required for smoothing




%% Initialize S structure
%  Sometime after setting any options, run JP_INIT, which sets defaults for
%  all the stages you want to run.
S = jp_init(S);


% At this point you could save the S structure (save S S), and then add
% subjects as you run more people some time in the future:
% load S
% S = jp_addsubject(S, 'mysubject1');
% S = jp_addsubject(S, 'mysubject2');
% save S S % re-save with the new subjects
% S = jp_run(S);



%% Add some subjects to process
S = jp_addsubject(S, 'subject1');




%% Run the analysis
S = jp_run(S);


% (After running, you may want to save S again to keep a record of the
% values used. Alternately you can set S.cfg.options.saveS to 1, which will
% automatically save S in the folder containing S.subjdir everytime you run
% JP_RUN; this is the default.  The record of analyses kept in S will be
% more complete if you load S to run it instead of creating it from a blank
% structure each time, but it's probably not a big deal.)

