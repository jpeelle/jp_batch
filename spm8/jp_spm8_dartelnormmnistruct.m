function S = jp_spm8_dartelnormmnistruct(S)
%JP_SPM8_DARTELNORMMNISTRUCT Write MNI structural images.
%
% S = JP_SPM8_DARTELNORMMNISTRUCT(S) will write MNI-normalized
% structural images following the creation of a DARTEL template.
%
% Note that this function also does Gaussian smoothing (default 8
% mm FWHM).
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
  jp_log(normlog, sprintf('Getting flowfields and images for subject %s...', S.subjects(s).name));
  
  darteldir = fullfile(S.subjdir, S.subjects(s).name, S.subjects(s).structdirs{1}, S.cfg.options.dartelname);
  
  % flow fields
  job.data.subj(s).flowfield{1} = spm_select('fplist', darteldir, '^u.*nii');
  
  % images
  imgs = [];
  
  for k=1:2
    imgs=strvcat(imgs, spm_select('fplist', darteldir, sprintf('^rc%d.*nii',k)));
  end
  
  job.data.subj(s).images = cellstr(imgs);
  
  jp_log(normlog, 'done.\n');
  
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

