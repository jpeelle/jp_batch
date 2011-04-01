function S = jp_spm8_normalize(S, subnum, sessionnum)
%JP_SPM8_NORMALIZE Normalize images using SPM8.
%
% S = JP_SPM8_NORMALIZE(S, SUBNUM, [SESSIONNUM]) normalizes images
% for subject number SUBNUM from an S structure (see JP_INIT).
%
% Options available in S.cfg.jp_spm8_normalize include:
%    prefix   Might be 'r' if you resliced previously (default '')
%
% See JP_DEFAULTS for a full list and defaults.
%
% The assumption is that segmentation (JP_SPM8_SEGMENT) has been
% done, resulting in a *seg_sn.mat file, the parameters of which
% will then be applied to all functional images.

% Jonathan Peelle
% University of Pennsylvania


% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);


subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

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

try
  structprefix = S.subjects(subnum).structprefix;
catch
  structprefix = jp_getinfo('structprefix', S.subjdir, subname);
end

try
  structdir = S.subjects(subnum).structdirs;
catch
  structdir = jp_getinfo('structdirs', S.subjdir, subname);
end

structdir = structdir{1};

% If no session specified, run on all sessions
if nargin < 3
  sessionnum = 1:length(fundirs);
end


% log files
[alllog, errorlog, normalizelog] = jp_createlogs(subname, S.subjdir, mfilename);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get normalization parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% The normalization file created by segmentation
seg_norm_file = spm_select('fplist',fullfile(S.subjdir, subname, structdir), sprintf('seg_sn\\.mat$',structprefix));

if size(seg_norm_file,1) > 1
  jp_log(errorlog, 'More than one *seg_sn.mat file found.', 2);
elseif isempty(seg_norm_file) || strcmp(seg_norm_file, '/')
  jp_log(errorlog, 'Segmentation normalization not found.', 2);
end

jp_log(normalizelog, sprintf('Normalization paramaters found in: %s\n', seg_norm_file), 1);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get files to normallize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P = jp_getfunimages([cfg.prefix funprefix], S.subjdir, subname, fundirs(sessionnum), S.cfg.options.mriext);

if size(P,1)==1 && strcmp('/', P(1,:))
  jp_log(errorlog, 'Did not find any images. Check to make sure your imagePrefix is correct.', 2);
end



% Get volume of these files
jp_log(normalizelog, sprintf('Creating volumes of %i files...',size(P,1)));
V = spm_vol(P);
jp_log(normalizelog, 'done creating volumes.\n');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

% How many digits (for writing out)
total_images = length(V);
ndigits = length(sprintf('%i',total_images));
nback = (2*ndigits)+1; % all the digits + a /

str = sprintf('Writing images: %s/%s\n',sprintf('%%%ii',ndigits),sprintf('%%%ii',ndigits));
fprintf(str,0,total_images)

jp_log(normalizelog, 'Writing images...', 0);
  
for thisv=1:length(V)
  spm_write_sn(V(thisv),seg_norm_file,cfg.write);  
  str = sprintf('%%s%s/%s',sprintf('%%%ii',ndigits),sprintf('%%%ii',ndigits));
  fprintf(str,sprintf(repmat('\b',1,nback)),thisv,total_images); 
end

jp_log(normalizelog, 'Done writing images.\n');

