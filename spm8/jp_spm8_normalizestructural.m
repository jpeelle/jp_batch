function S = jp_spm8_normalizestructural(S, subnum)
%JP_SPM8_NORMALIZESTRUCTURAL Normalizes subject's structural image.
%
% S = JP_SPM8_NORMALIZESTRUCTURAL(S, SUBNUM) normalizes the structural
% image(s) for subject number SUBNUM from an S structure (see
% JP_INIT).
%
% For now this assumes that a *seg_sn.mat file exists from running
% segmentation.
%
% By default this will normalize the bias-corrected image (m*)
% created during segmentation. This can be changed in:
%
%  S.cfg.jp_spm8_normalizestructural.prefix


% Jonathan Peelle
% University of Pennsylvania

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);


subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

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

structdir = structdir{1}; % use the first one

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

P = jp_getstructimages([cfg.prefix structprefix], S.subjdir, subname, structdir);

if size(P,1)==1 && strcmp('/', P(1,:))
  jp_log(errorlog, 'Did not find any images. Check to make sure your prefix is correct.', 2);
end



% Get volume of these files
jp_log(normalizelog, sprintf('Creating volumes of %i files...',size(P,1)));
V = spm_vol(P);
jp_log(normalizelog, 'done creating volumes.\n');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

jp_log(normalizelog, 'Writing images...');
  
for thisv=1:length(V)
  spm_write_sn(V(thisv),seg_norm_file,cfg.write);  
end

jp_log(normalizelog, 'done writing images.\n');


