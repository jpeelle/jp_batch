function S = jp_spm5_coregister(S, subnum)
%JP_SPM5_COREGISTER Coregister images using SPM5.
%
% S = JP_SPM5_COREGISTER(S, SUBNUM) will coregister images for
% subject number SUBNUM from an S structure (see JP_INIT).
%
% Options in S.cfg.jp_spm5_coregister include:
%   prefix  Before 'mean' in the mean functional
%
% JP_SPM5_COREGISTER tries to coregister the mean functional
% (^mean.*.nii in first functional directory) to the structural
% image.
%
% See JP_DEFAULTS for a full list and defaults.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



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
  fundirs = S.subjects(subnum).fundirs;
catch
  fundirs = jp_getinfo('fundirs', S.subjdir, subname);
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

if ischar(structdir)
  structdir = cellstr(structdir);
end



% log files
[alllog, errorlog, coregisterlog] = jp_createlogs(subname, S.subjdir, mfilename);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get mean functional image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jp_log(coregisterlog, 'Looking for mean functional image...\n')

meanfun = spm_select('fplist', fullfile(subdir, fundirs{1}), sprintf('^mean%s%s.*\\.nii', cfg.prefix, funprefix));

if isempty(meanfun) || strcmp(meanfun, '/') || size(meanfun,1) ~= 1
  jp_log(errorlog, sprintf('Error finding mean functional image (found %s)', meanfun), 2);
elseif size(meanfun,1) > 1
  jp_log(errorlog, 'More than one mean functional image found.', 2);
end

jp_log(coregisterlog, sprintf('Found %s.\n', meanfun));




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get structural image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jp_log(coregisterlog, 'Looking for structural image...\n');
structimage = jp_getstructimages(structprefix, S.subjdir, subname, structdir(1));

if size(structimage,1) > 1
  structimage = structimage(1,:);
  jp_log(coregisterlog, sprintf('Warning, more than 1 structural image found, using first: %s.\n', structimage), 1);
end
  
if isempty(structimage) || strcmp(structimage, '/')
  jp_log(errorlog, 'No structural image found!', 2);
end

jp_log(coregisterlog, sprintf('Found %s.\n', structimage));



VG = spm_vol(meanfun);
VF = spm_vol(structimage);

jp_log(coregisterlog, 'Running coregistration...\n');

x = spm_coreg(VG, VF);
M = inv(spm_matrix(x));
MM = spm_get_space(structimage);
spm_get_space(structimage,M*MM);

jp_log(coregisterlog, 'Finished coregistration.\n');

fprintf('** Make sure you check the results at some point (using CheckReg)! **\n');
