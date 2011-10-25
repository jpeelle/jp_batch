% Everything needed to run an analysis (or to see what has been run in a
% previous analysis) for a given study is found in the S structure, which
% is usually saved to S.mat in the main study folder. This should easily
% let you add subjects or stages to a study, or see what has been run, at
% any time. If you pass a properly-formatted S structure to JP_RUN, all
% stages and subjects will be run (unless they have been run previously,
% etc.).
%
% Because everything for your analysis is contained in the S structure,
% you need to keep track of it.  Note that many functions will return an
% updated S structure; for example, S = jp_init(S) is correct; simply
% running jp_init(S) with no output won't work.
%
% The minimum fields you need in S are the subject directory, some analysis
% stages to run, and some subjects to run.
%
% The cfg field (S.cfg) contains all options for determining how the
% analysis is done, and all configurable options for any processing stage.
% See JP_DEFAULTS for all available options.
%
% JP_INIT fills in subject-specific values for sessions, directories, etc.
% based on info.* text files; see JP_BATCH and JP_SPM_SETUP for more.


% This is a very minimal script that does not use JP_RUN, just to quickly
% look at movement parameters. You will need to use JP_SPM_SETUP to create
% some files to indicate the names of your sessions, however.  Also, these
% scripts assume you've run tsdiffana and that each session has a
% timediff.mat file.



%% add necessary paths (unless you add these somehwere else)
%  Because the various functions live in subfolders, you need to either (a)
%  add those to your Matlab path, or (b) run the following command, which
%  adds all subfolders. This assumes the jp_batch directory is in your
%  path (e.g., addpath /imaging/jp01/jp_batch, or whever you installed it).
%  Then:

jp_batch('addpaths');



%% Now, run jp_spm_setup, and set up a 'subject' directory.


%% Create a blank S structure where subjects and options will be added

S = struct();
S.subjdir = '/imaging/path/to/directory/where/your/subjects/are/';


%% Add some subjects

S = jp_addsubject(S, 'subject1');
S = jp_addsubject(S, 'subject2');
% etc...add all subjects.


%% Options are in S.cfg.(whatever the name of the function is). So for
%% jp_spm8_viewbadscans, options are in S.cfg.jp_spm8_viewbadscans.

S.cfg = []; % this is blank, so just use the defaults


% change defaults if you want like so:
%S.cfg.jp_spm8_viewbadscans.trans_x = .05;
%S.cfg.jp_spm8_viewbadscans.trans_y = ...


%% Now run the function
S = jp_spm8_viewbadscans(S);


%% If you want to create a text file with all of the bad scans for each
%% subject, you can use the code below.  This also runs the function using
%% the JP_RUN function.
% (you can change the thresholds for what gets counted as a 'bad' scan in
% S.cfg.jp_spm8_getbadscans, as above)

%S = jp_addanalysis(S, 'jp_spm8_getbadscans');  % add this analysis to be run
%S = jp_init(S);                                % this sets default values
%S = jp_run(S);                                 % run the function for all subjects

