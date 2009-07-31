function [alllog, errorlog, thislog] = jp_createlogs(thisSub, subjDir, logname, analysisname)
%JP_CREATELOGS Initialize log files and return paths.
%
% [alllog, errorlog, thislog] = JP_CREATELOGS(thisSub,
% subjDir, logname)

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



if nargin < 4
  analysisname = '';
end

if ~isdir(subjDir)
    error('%s not found.', subjDir);
end

subjDir = fullfile(subjDir, thisSub);


% Get the names of the logs
alllog = fullfile(subjDir,'jplog-all');
errorlog = fullfile(subjDir,'jplog-error');
thislog = fullfile(subjDir,sprintf('jplog%s-%s', analysisname, logname));

% The current log should be cleared for this run
fid = fopen(thislog,'w');
if fid==0
    error('Could not create %s.', thislog);
end
fclose(fid);
