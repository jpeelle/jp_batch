function S = jp_addsubject(S, subjects, force);
%JP_ADDSUBJECT Add subject to existing S structure.
%
% S = JP_ADDSUBJECT(S, SUBJECTS, [FORCE]) adds information for
% SUBJECTS to an existing S structure.
%
%    S = JP_ADDSUBJECT(S, 'subject1')
%
%    or
%
%    S = JP_ADDSUBJECT(S, {'subject2' 'subject3'})
%
%
% Because some information is not required for all studies, it
% checks to see whether information is available, and only adds
% what it finds. This is based on the info.* files (see JP_BATCH and
% JP_SPM_SETUP).
%
% If a subject exists in S already, nothing is changed. To replace
% information from a subject, set FORCE to 1.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



if ischar(subjects)
  subjects = cellstr(subjects);
end

if nargin < 3
  force = 0;
end

n = []; % haven't set which subject


if ~isfield(S, 'subjects')
  S.subjects = struct();
  n = 1; % this is the first subject
end


for i=1:length(subjects)
  
  thissub = subjects{i};

  fprintf('\nAdding subject %s...\n', thissub);
  
  runsub = 1; % by default run this subject 
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % check to see whether this subject exists already
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  
  oldsub = 0;
  if isfield(S.subjects,'name') % only bother checking if there are any    
    for m=1:length(S.subjects)
      if strcmp(thissub,S.subjects(m).name)
        oldsub = m;
      end
    end
  end
  
  if oldsub > 0
    if force > 0
      n = m; % replace
      fprintf('Subject %s previously added; replacing.\n', thissub);
      S.subjects(n) = []; % wipe out old info
    else
      runsub = 0; % don't run
      fprintf('Subject %s previously added, skipping. To replace use the FORCE argument of JP_ADDSUBJECT.\n', thissub);
    end
  end


  % If the subject wasn't previously found, just append to end of
  % list
  if isempty(n)
    n = length(S.subjects) + 1
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Add this subject
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if runsub > 0
    
    S.subjects(n).name = thissub;
    S.subjects(n).error = 0;
    
    if ~isdir(fullfile(S.subjdir, thissub))
      error('Subject directory %s not found.', fullfile(S.subjdir, thissub));
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % functional directories and prefix
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    try
      fundirs = jp_getinfo('fundirs', S.subjdir, thissub);
      fprintf('Added functional directories:\n');
      for j=1:length(fundirs)
        S.subjects(n).sessions(j).name = fundirs{j};
        fprintf('\t%s\n', fundirs{j});
        
        if ~isdir(fullfile(S.subjdir, thissub, fundirs{j}))
          error('%s specified (in info.fundirs file) but does not exist.', fundirs{j});
        end
      end    
    catch
      fundirs = [];
      S.subjects(n).sessions = [];
      fprintf('No functional directories specified.\n');
    end
    S.subjects(n).fundirs = fundirs;
    
    
    try
      funprefix = jp_getinfo('funprefix', S.subjdir, thissub);
      fprintf('Add functional prefix %s.\n', funprefix);
    catch
      funprefix = '';
      fprintf('No functional prefix found.\n')
    end
    S.subjects(n).funprefix = funprefix;
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % structural directories and prefix
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    try
      structdirs = jp_getinfo('structdirs', S.subjdir, thissub);
      fprintf('Added structural directories:\n');
      for j=1:length(structdirs)
        fprintf('\t%s\n', structdirs{j});
        if ~isdir(fullfile(S.subjdir, thissub, structdirs{j}))
          fprintf('WARNING: %s specified but does not exist.\n', structdirs{j});
        end
      end    
    catch
      structdirs = [];
      fprintf('No structural directories specified.\n');
    end
    S.subjects(n).structdirs = structdirs;
    
    
    try
      structprefix = jp_getinfo('structprefix', S.subjdir, thissub);
      fprintf('Add structural prefix %s.\n', structprefix);
    catch
      structprefix = '';
      fprintf('No structural prefix found.\n')
    end
    S.subjects(n).structprefix = structprefix;
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If functional directories, look for relevant values (TR,TA...)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if ~isempty(fundirs)
      fields = {'tr' 'ta'};
      for k=1:length(fundirs)
        thisd = fundirs{k};
        
        for f=1:length(fields)
          fn = fields{f};
          try
            x = jp_getinfo(fn, S.subjdir, thissub, thisd);
            S.subjects(n).sessions(k).(fn) = x;
            fprintf('Added %s = %g for session %s.\n', fn, x, thisd);
          catch
            fprintf('No %s found for session %s.\n', fn, thisd);
          end
          
        end % going through fields
      end % going through sessions      
    end % checking if fundirs is empty
  end % running this subject
end % going through subjects to add
