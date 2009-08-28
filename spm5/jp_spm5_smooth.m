function S = jp_spm5_smooth(S, subnum, sessionnum)
%JP_SPM5_SMOOTH Smooth images using SPM5.
%
% S = JP_SPM5_SMOOTH(S, SUBNUM, [SESSIONNUM]) will smooth images
% for subject number SUBNUM from an S structure (see JP_INIT).
%
% Required option in S.cfg.jp_spm5_smooth is the fwhm field.  Other
% options:
%  fwhm     specify FWHM in mm (default [])
%  prefix   prefix to images being smoothed (default 'w')
%
% See JP_DEFAULTS for a full list of defaults.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

% log files
[alllog, errorlog, smoothlog] = jp_createlogs(subname, S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);

if ~isfield(cfg, 'fwhm') || isempty(cfg.fwhm)
  jp_log(errorlog, 'Must specify S.cfg.jp_spm5_smooth.fwhm.', 2);
end



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
% Get files to smooth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jp_log(smoothlog, 'Getting images...');
P = jp_getfunimages([cfg.prefix funprefix], S.subjdir, subname, fundirs(sessionnum));

if size(P,1)==1 && strcmp('/', P(1,:))
  jp_log(errorlog, 'Did not find any images. Check to make sure your imagePrefix is correct.', 2);
end

jp_log(smoothlog, sprintf('%i images found.\n', size(P,1)));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Smooth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

% How many digits?
total_images = size(P,1);
ndigits = length(sprintf('%i',total_images));
nback = (2*ndigits)+1; % all the digits + a /

jp_log(smoothlog, 'Smoothing images...', 0);

str = sprintf('Smoothing images: %s/%s',sprintf('%%%ii',ndigits),sprintf('%%%ii',ndigits));
fprintf(str,0,total_images)

for thisp=1:size(P,1)
  thisFile = deblank(P(thisp,:));
  [pathstr,name,ext,versn] = fileparts(thisFile);
  spm_smooth(thisFile,fullfile(pathstr,sprintf('s%i%s.nii',cfg.fwhm,name)),cfg.fwhm);
  
  % Print out how far along we are
  str = sprintf('%%s%s/%s',sprintf('%%%ii',ndigits),sprintf('%%%ii',ndigits));
  fprintf(str,sprintf(repmat('\b',1,nback)),thisp,total_images);
end

fprintf('\n');
jp_log(smoothlog, 'Done smoothing images.\n');







