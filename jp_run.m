function S = jp_run(S, subjects, stages, aa)
%JP_RUN Runs processing for a study.
%
% S = JP_RUN(S, [SUBJECTS], [STAGES]) uses the information stored in S
% to process data for an imaging study. SUBJECTS let you specify which
% subjects you want to run, if not all. STAGES lets you specify which
% stages you want run (if not all).  If ommitted all subjects and all
% stages are run.  This lets you, for example, set up all stages of
% a study with default parameters, but not actually run them
% all. SUBJECTS and STAGES are vectors of integers corresponding to
% the subject number or analysis stage number in S.
%
% The S structure contains information required for running all
% parts of a study. Generally you would prepare this using
% JP_INIT to set in default values for all stages. However,
% once you have set up S, you can save it as a .mat file, and
% simply re-load it to add subjects:
%
%    load S
%    S = JP_ADDSUBJECT(S, 'subject1');
%    save S S
%
%    JP_RUN(S)
%
%
% See JP_BATCH and JP_INIT for more information.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


% undocumented option: aa: 0 = no | 'aa' | 'aa_parallel'

% get the analysis name for adding to done flag and log
analysisname = S.cfg.options.analysisname;
if ~isempty(analysisname) && ~strcmp(analysisname(1),'-')
  analysisname = ['-' analysisname];
end

logfile = fullfile(S.subjdir, sprintf('jplog-jp_run%s',analysisname));

if nargin < 4
  aa = '';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get ready to run
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  S.whichspm = which('spm');
catch
  S.whichspm = 'NO SPM FOUND';
end

try
  S.spmver = spm('Ver');
catch
  S.spmver = 'NO VERSION FOUND';
end

% make sure correct SPM version is being run
if ~isempty(S.cfg.options.spmver)
  if ~strcmp(S.spmver, upper(S.cfg.options.spmver))
    error('Requested SPM version %s but %s is in path.', S.cfg.options.spmver, S.spmver);
  end
end

jp_log(logfile, sprintf('SPM location: %s\n', S.whichspm));
jp_log(logfile, sprintf('SPM version: %s\n', S.spmver));


jp_log(logfile, '\n\n*********************************************************\n');
jp_log(logfile, '                     JP_RUN v1.0\n')
jp_log(logfile, '*********************************************************\n\n');

S.runtime = datestr(now);
fprintf('Started %s\n', S.runtime);

jp_log(logfile, sprintf('SPM location: %s\n', S.whichspm));
jp_log(logfile, sprintf('SPM version: %s\n', S.spmver));


% save S
if S.cfg.options.saveS || ~isempty(aa)
  [savdir, nm, ext] = fileparts(S.subjdir); % save one level up from subj
  sfile = fullfile(savdir, sprintf('S%s.mat',analysisname));
  save(sfile, 'S');
end

if nargin < 3 || isempty(stages)
  stages = 1:length(S.analysis);
end

if nargin < 2 || isempty(subjects)
  subjects = 1:length(S.subjects);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make sure SPM will run ok
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ismember('fMRI', S.cfg.options.modality)
  fprintf('Loading SPM defaults from %s...', S.cfg.options.spmdefaultsfunction);
  eval(S.cfg.options.spmdefaultsfunction);
  global defaults  
  defaults.modality = 'FMRI';
  defaults.stats.maxmem = 2^26;
  fprintf('done.\n');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For each subject, loop through analysis stages and run
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~isempty(aa)
  if ~isfield(S, 'aap')
    S.aap = struct();
  end
  
  S.aap = jp_S2aap(S, S.aap, sfile, subjects, stages);

  if S.cfg.options.saveS
    save(sfile, 'S');
  end
end


% clear error files
for s=1:length(subjects)
    ss = subjects(s);
    S.subjects(ss).error = 0;
end
    
% See if we want to run this as AA or normal
if strcmp(aa, 'aa')
  jp_log(logfile,'Running using AA.');
  S.aap = aa_doprocessing(S.aap);  
elseif strcmp(aa, 'aa_parallel')
  jp_log(logfile,'Running using AA Parallel.');
  S.aap = aa_doprocessing_parallel(S.aap);   
else
  
  % if requested start SPM,which initializes graphics windows (unless
  % we are not actually running stages)
  if S.cfg.options.startspm && S.cfg.options.runstages>0
    spm('fmri');
  end
  
  for a=1:length(stages)
    
    aa = stages(a);
    nm = S.analysis(aa).name;
    
    fprintf('\n\n---------------------------------------------------------\n');
    jp_log(logfile, sprintf('Running %s (%i/%i)\n', upper(nm), a, length(stages)), 1);
    fprintf('---------------------------------------------------------\n');
    
    for s=1:length(subjects)          
      ss = subjects(s); % the subject we want to run      
      subjname = S.subjects(ss).name;
                  
      jp_log(logfile, sprintf('Subject %s (%i/%i)\n', subjname, s, length(subjects)));      
      donefile = fullfile(S.subjdir, subjname, sprintf('jpdone%s-%s-%s', analysisname, subjname, nm));      
      errorfile = fullfile(S.subjdir, subjname, 'jplog-error');
      
      % check for existing error file
      if S.cfg.options.checkforerrors==1 && exist(errorfile)
        jp_log(logfile, sprintf('Error log exists for subject %s; skipping.\n\n', subjname), 1);
        S.subjects(ss).error = 1;
        
        % check to see if this stage has been completed already (per subject, not per session)
      elseif S.cfg.options.checkfordone==1 && exist(donefile)                                                      
        jp_log(logfile, sprintf('Stage %s already completed for subject %s; skipping.\n\n', upper(nm), subjname), 1);
        
      else
        % if no error or file, or not checking, try to run this stage
        
        cmd = sprintf('S = %s(S, %i);', S.analysis(aa).name, ss);
        
        if S.cfg.options.runstages==0
          fprintf('Would run %s for %s.\n', upper(S.analysis(aa).name), subjname);
        else
          try
            % logs for this stage for this subject
            [alllog, errorlog, thislog] = jp_createlogs(subjname, S.subjdir, S.analysis(aa).name);
            
            jp_log(thislog, sprintf('Starting %s for subject %s...\n', upper(S.analysis(aa).name), subjname));
            S.subjects(ss).(nm).starttime = datestr(now);
            eval(cmd);
            S.subjects(ss).(nm).endtime = datestr(now);
            
            % save S every time if requested, just in case
            % something crashes before everything has been run
            if S.cfg.options.saveS
              save(sfile, 'S');
            end
            
            % if it worked (i.e. no error by here)  make a done file
            system(sprintf('touch %s', donefile));
            
            % make an aa-compatible subject-level flag
            if S.cfg.options.aadoneflags
              system(sprintf('touch %s', fullfile(S.subjdir, subjname, sprintf('done_aamod_%s', nm))));
            end
            
            jp_log(thislog, sprintf('Finished %s for subject %s.\n', upper(S.analysis(aa).name), subjname));
            
          catch
            % If there was a problem, make note of the error, and log it
            S.subjects(ss).error = 1;
            S.subjects(ss).errmessage = '';
            S.subjects(ss).errstack = '';
            
            err = lasterror;
            
            for em=1:size(err.message,1)
              S.subjects(ss).errmessage = [S.subjects(ss).errmessage err.message(em,:)];
              jp_log(logfile, sprintf('%s\n', err.message(em,:)), 0);
              jp_log(errorlog, sprintf('%s\n', err.message(em,:)));
            end
            
            for es=1:length(err.stack)
              S.subjects(ss).errstack = [S.subjects(ss).errstack sprintf('In %s line %i\n',err.stack(es).file,err.stack(es).line)];
              jp_log(errorlog, sprintf('In %s line %i\n', err.stack(es).file, err.stack(es).line), 0);
              jp_log(logfile, sprintf('In %s line %i\n', err.stack(es).file, err.stack(es).line));
            end
          end % try/catch
        end % checking to see if we actually run
      end % checking for errors
      
    end % going through subject
  end % going through analysis stages  
end % checking for AA


% save S (again, since things were added during analysis)
if S.cfg.options.saveS
  save(sfile, 'S');
  jp_log(logfile, sprintf('S structure saved to %s.\n', sfile));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Report how many subjects were successfully processed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if S.cfg.options.runstages > 0
  fprintf('\n\n')
  jp_log(logfile, '*********************************************************\n');
  jp_log(logfile, sprintf('%i subjects were processed successfully:\n', sum([S.subjects(subjects).error]==0)));
  for s=1:length(subjects)
    ss = subjects(s);
    if S.subjects(ss).error==0
      jp_log(logfile, sprintf('\t%s\n', S.subjects(ss).name));
    end
  end  
  
  jp_log(logfile, sprintf('\n%i subjects had errors:\n', sum([S.subjects(subjects).error])));
  for s=1:length(subjects)
    ss = subjects(s);
    if S.subjects(s).error==1
      jp_log(logfile, sprintf('\t%s\n', S.subjects(ss).name));
    end
  end
  fprintf('\n')
else
  fprintf('\nDone.\n');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Try to make everything you just did group read/writeable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if S.cfg.options.chmodgrw
    system(sprintf('chmod -R g+rw %s', S.subjdir));
end
