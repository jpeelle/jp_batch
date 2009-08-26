function S = jp_spm8_dartelnormmnifun(S)
%JP_SPM8_DARTELNORMMNIFUN Write MNI functional images.
%
% S = JP_SPM8_DARTELNORMMNIFUN(S) will write MNI-normalized
% functional images following the creation of a DARTEL template.
%
% Note that this function also does Gaussian smoothing (default 10
% mm FWHM).
%
% The default voxel size is 2 x 2 x 2.
%
% See JP_DEFAULTS_SPMFMRI for a full list of defaults.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



% log files
[alllog, errorlog, normlog] = jp_createlogs('', S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);

jp_log(normlog, sprintf('Using %s.\n', which('spm_dartel_norm_fun')));

% Where are the templates?
templatedir = fullfile(S.subjdir, sprintf('templates_%s', S.cfg.options.dartelname));
template = spm_select('fplist', templatedir, '^Template_6\.nii$');

if isempty(template) || strcmp(template, '/')
  jp_log(normlog, 'Could not find Template6.nii.', 2);
end

% Get images
allimages = {};

for s=1:length(S.subjects)
  jp_log(normlog, sprintf('Getting flowfields and images for subject %s...\n', S.subjects(s).name));
  
  darteldir = fullfile(S.subjdir, S.subjects(s).name, S.subjects(s).structdirs{1}, S.cfg.options.dartelname);
  
  % flow fields
  job.data.subj(s).flowfield{1} = spm_select('fplist', darteldir, '^u.*nii');
  
  % images
  prefix = [cfg.prefix S.subjects(s).funprefix];
  imgs = jp_getfunimages(prefix, S.subjdir, S.subjects(s).name, jp_getsessions(S,s));

  if isempty(imgs) || strcmp(imgs, '/')
    jp_log(errorlog, sprintf('No images found for subject %s.', S.subjects(s).name), 2);
  end
  
  jp_log(normlog, sprintf('\t%i images found.\n', size(imgs,1)));
    
  job.data.subj(s).images = cellstr(imgs);
  
end % goign through subjects

% set up the job
jp_log(normlog, 'Setting up normalization job...');

job.template{1} = template;
job.bb = nan(2,3);
job.vox = ones(1,3) * cfg.vox;
job.fwhm = cfg.fwhm;
job.preserve = cfg.preserve;

jp_log(normlog, 'done.\n');

jp_log(normlog, 'Registering to MNI, then normalizing each subject:\n\n');
spm_dartel_norm_fun(job);

