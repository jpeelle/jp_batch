function S = jp_spm8_movefirstscans(S, subnum, sessionnum)
%JP_SPM8_MOVEFIRSTSCANS Move first scans in a session.
%
% S = JP_SPM8_MOVEFIRSTSCANS(S, SUBNUM) will move images for each
%functional session into a FIRSTSCANS folder.
%
% The number of scans moved is set in S.cfg.jp_spm8_movefirstscans (default 4).
%

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit

subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

% log files
[alllog, errorlog, movelog] = jp_createlogs(subname, S.subjdir, mfilename);

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
  
  jp_log(movelog, sprintf('Session %s\n', sessions{s}));
  
  % output
  movedir = fullfile(S.subjdir, subname, sessions{s}, 'FIRSTSCANS');
  if ~isdir(movedir)
    jp_log(movelog, sprintf('Creating %s.\n', movedir));
    mkdir(movedir);
  end
  
  % get the images
  jp_log(movelog, 'Getting images...');
  P = jp_getfunimages([cfg.prefix funprefix], S.subjdir, subname, sessions{s});
  jp_log(movelog, sprintf('%i total images found.\n', size(P,1)));
  
  % assume that the images are sorted appropriately
  jp_log(movelog, sprintf('Moving %i images...', cfg.numscans));
  for j=1:cfg.numscans
    system(sprintf('mv %s %s/', deblank(P(j,:)), movedir));    
  end
  jp_log(movelog, 'done.\n');
end

jp_log(movelog, 'All done.\n');
