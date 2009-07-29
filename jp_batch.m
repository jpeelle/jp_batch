function jp_batch(task)
%JP_BATCH Run batch scripts (e.g., for SPM).
%
% The general approach is that all of the information required for
% running a study (or knowing what was done) is stored in a single
% Matlab structure, S.  S has a list of all the stages of analysis
% to be run (in S.analysis) and subjects (S.subjects).
%
% JP_INIT(S) initializes the S structure, getting defaults for
% the stages that are to be run. JP_RUN(S) will then run through
% all the stages for each subject. S can be saved and referred to
% later to see what stages were run. In addition, JP_RUN can keep
% track of what stages have been run for each subject, so you can
% simply add subjects to S and re-run the analysis, and not worry
% about re-doing any previously-completed stages.
%
% Instead of using JP_RUN it is also possible to use functions on
% their own. For example scripts, look in the examplescripts
% folder.
%
%
% --------------------------------------------------------------
% Where functions are
% --------------------------------------------------------------
%
% Most of the important functions are in subdirectories within the
% main folder. If you run JP_INIT or JP_RUN these folders are
% automatically added to your path. Otherwise, you can add them
% using ADDPATH or File > Set Path, or by running
% JP_BATCH('addpaths').
%
%
% --------------------------------------------------------------
% Setting study parameters (including any that differ by subject)
% --------------------------------------------------------------
%
% Some of the study information is stored in text files in each
% subject's directory in info.* files.  This allows different
% processing for different subjects (e.g. different number of
% functional directories), and also allows this basic information to
% be read by other scripts. JP_SPM_SETUP will help create these files,
% or you can make them in any text editor.
%
% Required info files in the top-level subject directory are:
%  info.tr
%  info.ta
%
% These can be overwritten within each subject's directory by with:
%  subjectname.info.fundirs
%
% And in some cases at the session level with
%  sessionname.subjectname.info.tr
%
%
% The S structure contains a list of subjects, basic information
% about the study, and a list of analysis stages.  Each stage name
% corresponds to a function, and allows the setting of options.
%
% For all functions, the help differs slightly from standard Matlab
% functions. Arguments in brackets are optional, others are
% required.  For example, for the helper function JP_GETFUNIMAGES:
%
% JP_GETFUNIMAGES(SUBJDIR, SUBNUM, [SESSIONNUM])
%
% Indicates that S and the subject number are required, but that
% the session number is optional (in this case, if the session
% number is not specified, functional images for all directories
% are returned).
%
% Once S is set up, all stages for all subjects can be run using
% JP_RUN. Individual functions can be used without JP_RUN; in this
% case, generally only minimal information is required in S,
% typically: S.subjdir S.subjects (for names); if missing, other
% information is read in from info files at run time.
%  
%
% --------------------------------------------------------------
% Options and defaults
% --------------------------------------------------------------
%
% Nearly every analysis function has some optional arguments which
% determine how it works. This are stored in S.cfg.(function_name).
%
% How to set these options changes somewhat depending on how the
% functions are called.  If you are running a whole analysis using
% JP_RUN, default values should be set prior to running using
% JP_INIT. By looking at the S structure you can see exactly what
% options were used.
%
% If the functions are run outside of JP_RUN, default values
% are set at run-time.
%
% Default values are stored in JP_SPM_DEFAULTS; it is possible to
% create a copy of this for each study with tweaked defaults,
% See JP_SPM_DEFAULTS and JP_INIT for more, and example scripts in
% the 'examples' directory.
%
%
% --------------------------------------------------------------
% JP_BATCH('addpaths')
% --------------------------------------------------------------
% 
% Adds subdirectories (if you don't do it yourself).


if nargin==0
    help('jp_batch')
elseif strcmp(lower(task), 'addpaths')
    % make sure subdirectories are added
    basedir = fileparts(which('jp_init'));
    files = dir(basedir);
    for f=1:length(files)
        if files(f).isdir==1 && isempty(findstr('.',files(f).name))
            addpath(fullfile(basedir, files(f).name));
        end
    end
else
  error('Unknown option.');
end
