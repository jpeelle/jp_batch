function jp_log(logfile, msg, verbose)
%JP_LOG helper function to print info to file/screen.
%
% JP_LOG(LOGFILE, MSG, VERBOSE)
%
% VERBOSE = 1 prints to screen
% VERBOSE = 2 indicates error

% Jonathan Peelle
% University of Pennsylvania

if nargin < 3
  verbose = 1;
end


% write to log file
fid = fopen(logfile, 'a');
nmsg = strrep(msg, '\n', '');
fprintf(fid, '%s\t%s\n', datestr(now), nmsg);
fclose(fid);


% write to screen
if verbose==1
  fprintf('%s', sprintf(msg));
end


if verbose > 1
  error(msg);
end
