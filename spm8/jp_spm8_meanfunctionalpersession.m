function S = jp_spm8_meanfunctionalpersession(S, subnum, sessionnum)
%JP_SPM8_MEANFUNCTIONALPERSESSION Make mean image for each session.
%
% S = JP_SPM8_MEANFUNCTIONALPERSESSION(S, SUBNUM) will make a mean
% image for each functional session.
%
% The number of scans moved is set in S.cfg.jp_spm8_movefirstscans (default 4).
%

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit

subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

% log files
[alllog, errorlog, meanlog] = jp_createlogs(subname, S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);

try
  funprefix = S.subjects(subnum).funprefix;
catch
  funprefix = jp_getinfo('funprefix', S.subjdir, subname);
end

try
  sessions = jp_getsessions(S, subnum);
catch
  sessions = jp_getinfo('sessions', S.subjdir, subname);
end

% If no session specified, run on all sessions
if nargin < 3
  sessionnum = 1:length(sessions);
end





for i=1:length(sessionnum)
  s = sessionnum(i);
  
  jp_log(meanlog, sprintf('Session %s\n', sessions{s}));
  
  % get the images
  jp_log(meanlog, 'Getting images...');
  P = jp_getfunimages([cfg.prefix funprefix], S.subjdir, subname, sessions{s});
  jp_log(meanlog, sprintf('%i total images found.\n', size(P,1)));
  
  % where should we save the mean to?
  if isempty(cfg.meanname)
    meanname = sprintf('%smean%s.nii', sessions{s}, cfg.prefix);
  end
  outfile = fullfile(S.subjdir, subname, sessions{s}, meanname);

  jp_log(meanlog, 'Creating mean...');
  jp_spm_mean(P, struct('fname', outfile));
  jp_log(meanlog, 'done.\n');
end

jp_log(meanlog, 'All done.\n');
