function S = jp_spm8_tsdiffana(S, subnum, sessionnum)
%JP_SPM8_TSDIFFANA Timeseries difference analysis on fMRI data.
%
% S = JP_SPM8_TSDIFFANA(S, SUBNUM, [SESSIONNUM]) will perform
% timeseries difference analysis on sessions using the TSDIFFANA
% script (contained in externals/ folder), saving the ouput within
% each directory as subjectname_sessionname_tsdiffana.png.

% Jonathan Peelle
% University of Pennsylvania

subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

% log files
[alllog, errorlog, tsdifflog] = jp_createlogs(subname, S.subjdir, mfilename);



% get session directories

try
  funprefix = S.subjects(subnum).funprefix;
catch
  funprefix = jp_getinfo('funprefix', S.subjdir, subname);
end

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
% do the tsdiffana
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s=1:length(sessionnum)
  
  ss = sessionnum(s);
  
  imgs = jp_getfunimages(funprefix, S.subjdir, subname, fundirs{ss}, S.cfg.options.mriext);
  
  if isempty(imgs)
    error('No images found.');
  end
  
  jp_log(tsdifflog, sprintf('Session %s: %d images selected.\n', fundirs{ss}, size(imgs,1)));
  
  f1 = figure('position', [360 39 663 884], 'color', 'w');
  
  jp_log(tsdifflog, 'Running tsdiffana...');
  tsdiffana(imgs, 0, f1);
  jp_log(tsdifflog, 'done.\n\n')
  
  print('-dpng', '-r100', fullfile(subdir, fundirs{ss}, sprintf('%s_%s_tsdiffana.png', subname, fundirs{ss})));
  
  close(f1);
end



