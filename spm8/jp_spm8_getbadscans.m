function S = jp_spm8_getbadscans(S, subnum, sessionnum)
%JP_SPM8_GETBADSCANS Produce a list of bad scans for each session.
%
% S = JP_SPM8_GETBADSCANS(S, SUBNUM, [SESSIONNUM]) will get bad
% scans for subject number SUBNUM from an S structure (see
% JP_INIT).
%
% "Bad scans" are defined as any scan where the scan-to-scan
% absolute difference in  movement parameters or TSDIFFANA
% parameters (if present) exceed pre-specified values, set as
% fields in S.cfg.jp_spm8_getbadscans:
%
%    trans_x  (mm)  default .24
%    trans_y  (mm)  default .24
%    trans_z  (mm)  default .24
%    rot_x    (rad) default .0035
%    rot_y    (rad) default .0035
%    rot_z    (rad) default .0035
%    timediff   (au)  default 6.0  
%
% The default values are taken from examining values over ~160
% subjects; the defaults are approximately 3 standard deviations
% away form the mean in all cases (collapsing across translations
% in all directions and rotations in all directions). It's probably worth
% checking on each specific scanner however...
%
% Any scan exceeding any value gets added to the jp_badscans.txt
% file in each session directory.
%
% See also JP_SPM8_TSDIFFANA.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

% log files
[alllog, errorlog, badlog] = jp_createlogs(subname, S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);

try
  fundirs = jp_getsessions(S, subnum);
catch
  fundirs = jp_getinfo('sessions', S.subjdir, subname);
end

% If no session specified, run on all sessions
if nargin < 3
  sessionnum = 1:length(fundirs);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize things that keep track of items over sessions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

totalscans = 0;
totalbad = 0;
rpthresh = [cfg.trans_x cfg.trans_y cfg.trans_z cfg.rot_x cfg.rot_y cfg.rot_z];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Go through each session and identify bad scans, and write out 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

for s=1:length(sessionnum)
  ss = sessionnum(s);
  jp_log(badlog, sprintf('Session %s...\n', fundirs{ss}));
  
  ss = sessionnum(s);
  
  sessdir = fullfile(subdir, fundirs{ss});
  fname = fullfile(sessdir, 'jp_badscans.txt');
  bad = [];
  
  % get rp
  rpfile = spm_select('fplist', sessdir, '^rp_.*\.txt');
  if isempty(rpfile) || strcmp(rpfile,'/')
    jp_log(badlog, 'Problem finding rp_*.txt file.', 2);
  elseif size(rpfile,1)>1
    jp_log(badlog, 'More than one rp_*.txt file found.', 2);
  else
    jp_log(badlog, sprintf('\tFound %s.\n', rpfile));
  end
  
  rp = dlmread(rpfile);     
  totalscans = totalscans + size(rp,1);
  
  rpdiff = diff(rp);
  
  % [The first scan is scan 0; since it's the first scan, it has no
  % difference image. So we just look at the differences in rpdiff;
  % this works out well because the first line in rpdiff is scan 1
  % (the second scan in the directory).]
  
  for i=1:size(rpdiff,1)
    if sum(abs(rpdiff(i,:)) > rpthresh) > 0
      bad = [bad i];
    end
  end
  
  
  
  % get tsdiff (if available)
  tsfile = spm_select('fplist', sessdir, '^timediff\.mat$');
  
  if isempty(tsfile) || strcmp(tsfile, '/')
    jp_log(badlog, '\tNo timediff.mat file found, so skipping (have you run tsdiffana?).\n');
  else
    jp_log(badlog, sprintf('\tFound %s.\n', tsfile));
    load(tsfile);
  end
 
  % scale by globals as done in tsdiffana plots
  td = td/mean(globals);
  
  bad = [bad find(td > cfg.timediff)'];
  
  bad = sort(unique(bad));
  
  jp_log(badlog, sprintf('\t%i bad scans for this session.\n\n', length(bad)));
  
  totalbad = totalbad + length(bad);
  
  
  dlmwrite(fname, bad, 'delimiter', '\n');
  
  clear td globals rp
  
end % going through sessions


jp_log(badlog, sprintf('TOTAL: %i/%i scans (%.1f%%%%) identified as bad.\n\n', totalbad, totalscans, 100*(totalbad/totalscans)));

