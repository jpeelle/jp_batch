function S = jp_spm8_coregisterstructural2template(S, subnum)
%JP_SPM8_COREGISTERSTRUCTURAL2TEMPLATE Coregister images using SPM8.
%
% S = JP_SPM8_COREGISTERSTRUCTURAL2TEMPLATE(S, SUBNUM) will coregister
% images for subject number SUBNUM from an S structure (see JP_INIT).
%
% Options in S.cfg.jp_spm8_coregisterstructural2template include:
%    move_functional    default 1, moves functional images along with structural to keep in line
%    functional_prefix  default '', can change if needed
%    template           what structural gets registered to (default avg152T1.nii)
%
% 
%
% See JP_DEFAULTS for a full list and defaults.

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

if ischar(structdir)
  structdir = cellstr(structdir);
end



% log files
[alllog, errorlog, coregisterlog] = jp_createlogs(subname, S.subjdir, mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get template image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
jp_log(coregisterlog, sprintf('Looking for template image %s...\n', cfg.template));

if ~exist(cfg.template)
  jp_log(errorlog, sprintf('Template %s not found.', cfg.template));
end

jp_log(coregisterlog, 'done.\n');


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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get functional images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if cfg.move_functional > 0
  % Get mean functional image
  jp_log(coregisterlog, 'Looking for mean functional image...\n')

  meanfun = spm_select('fplist', fullfile(subdir, fundirs{1}), sprintf('^mean%s%s.*\\.%s', cfg.functional_prefix, funprefix, S.cfg.options.mriext));

  if isempty(meanfun) || strcmp(meanfun, '/') || size(meanfun,1) ~= 1
    jp_log(errorlog, sprintf('Error finding mean functional image (found %s)', meanfun), 2);
  elseif size(meanfun,1) > 1
    jp_log(errorlog, 'More than one mean functional image found.', 2);
  end

  jp_log(coregisterlog, sprintf('Found %s.\n', meanfun));
  
  jp_log(coregisterlog, 'Looking for functional images...\n')
  funimages = jp_getfunimages([cfg.functional_prefix funprefix], S.subjdir, subname, jp_getsessions(S, subnum));
  
  funimages = strvcat(funimages, meanfun);  
  jp_log(coregisterlog, sprintf('Added %i functional images.\n', size(funimages,1)));
end



VG = spm_vol(cfg.template);
VF = spm_vol(structimage);

jp_log(coregisterlog, 'Running coregistration...\n');

x = spm_coreg(VG, VF, cfg.estimate);
M = inv(spm_matrix(x));

PO = structimage;

if cfg.move_functional
  PO = strvcat(PO, funimages);
end

MM = zeros(4,4,size(PO,1));

for j=1:size(PO,1)
  MM(:,:,j) = spm_get_space(deblank(PO(j,:)));
end

for j=1:size(PO,1)
  spm_get_space(deblank(PO(j,:)), M*MM(:,:,j));
end

jp_log(coregisterlog, 'Finished coregistration.\n');
fprintf('** Make sure you check the results at some point (using CheckReg)! **\n');
