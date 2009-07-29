function A = jp_getinfo(name, baseDir, subject, session)
%JP_GETINFO Get info used in JP batch scripts from a text file.
%
%  JP_GETINFO(NAME, BASEDIR, [SUBJECT], [SESSION]) gets the value from
%  a text file.  
%
%  Files at the top level are info.NAME and within the subject
%  directory, SUBJECT.info.NAME.  For example, the default TR would
%  be set by this file
%
%      BASEDIR/info.tr
%
%  and this can be overridden for subject JP503 by creating
%
%      BASEDIR/JP503/JP503.info.tr
%
%  or BASEDIR/JP503/session1/session1.JP503.info.tr
%
%
%  The order of checking for property XX is:
%
%  1) subjects/thissubject/subject.info.XX.session
%  2) subjects/thissubject/subject.info.XX
%  3) subjects/info.XX.session
%  4) subjects/info.XX
%
%  See JP_BATCH for a list of acceptable parameters to use.


p = {}; % path for keeping track of where we looked

if nargin==4
  session_file = fullfile(baseDir, sprintf('info.%s.%s', name, session));
  sessionsubject_file = fullfile(baseDir, subject, sprintf('%s.info.%s.%s', subject, name, session));  
end

if nargin>=3
  subject_file = fullfile(baseDir, subject, sprintf('%s.info.%s', subject, name));
end

base_file = fullfile(baseDir, sprintf('info.%s', name));


if nargin==4 
  p = {p{:} sessionsubject_file};
end

if nargin>=3
  p = {p{:} subject_file};
end

if nargin==4
  p = {p{:} session_file};
end

p = {p{:} base_file};


the_file = [];
i = 1;

while isempty(the_file) && i <= length(p)
  if exist(p{i})
    the_file = p{i};
  end
  i = i+1;
end

if isempty(the_file)
  fprintf('Unable to locate info.%s file.  Tried:\n', name);
  for i=1:length(p)
    fprintf('%s\n', p{i});
  end

  error(sprintf('Unable to locate info.%s file.', name));
end


A = readfile(the_file, name);

end % main function


function B = readfile(fileName,name)
%-----------------------------------------------
% EDIT THESE LISTS IF YOU NEED TO MAKE CHANGES
%-----------------------------------------------

stringList = {'structprefix',...
              'funprefix',...
              'event_units',...
              'bf_name'};

cellList = {'structdirs',...
            'fundirs',...
            'conditions',...
            'sessions',...
            'regressors'};
        
        
% Decide whether file is text or number, read it in, and return it.
if ismember(name,stringList)
  B = textread(fileName,'%s','delimiter','\n');
  B = B{1}; % make it a string
elseif ismember(name,cellList)
  tmp = textread(fileName,'%s','delimiter','\n');
  
  % Remove empty strings
  B = {};
  for i=1:length(tmp)
    if ~strcmp(tmp{i},'')
      B = {B{:} tmp{i}};
    end
  end
  
else
  B = dlmread(fileName);
end

end % readfile
