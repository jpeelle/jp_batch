function S = jp_spm8_createmeanstructural(S)
%JP_SPM8_CREATEMEANSTRUCTURAL Calculate a mean structural image.
%
% S = JP_SPM8_CREATEMEANSTRUCTURAL(S) will take (normalized)
% structrual images from a study and create a mean image. This
% might be useful, for example, in an fMRI study, for displaying
% results on. (You can use JP_SPM8_NORMALIZESTRUCTURAL to get these
% normalized structural images.)
%
%
% This must be run on the study level; i.e.:
%
%  S = jp_addanalysis(S, 'jp_spm8_createmeanstructural', 'study');
%
% See JP_DEFAULTS_SPMFMRI for a full list of defaults.

% Jonathan Peelle

% log files
[alllog, errorlog, meanlog] = jp_createlogs('', S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);

% make sure output file is a .nii file
if ~strcmp(cfg.name(end-4:end),'.nii')
  cfg.name = [cfg.name '.nii'];
end


% create output file, make sure it doesn't already exist
outputname = fullfile(S.subjdir, cfg.name);

if exist(outputname)
  jp_log(meanlog, sprintf('Specified outputfile %s already exists.', outputname), 2);
end

% get structural images
P = [];

for i=1:length(S.subjects)
  subname = S.subjects(i).name;
  prefix = sprintf('%s%s', cfg.prefix, S.subjects(i).structprefix);
  jp_log(meanlog, sprintf('Getting images for subject %i/%i %s...', i, length(S.subjects), subname));
  tmp = jp_getstructimages(prefix, S.subjdir, subname, S.subjects(i).structdirs);
  jp_log(meanlog, sprintf('done. %i found.\n', size(tmp,1)));
  for j=1:size(tmp,1)
    jp_log(meanlog, sprintf('\t%s\n', strtok(tmp(j,:))));
  end
  P = strvcat(P, tmp);  % add these tmp images to the list  
end

jp_log(meanlog, sprintf('%i total images found.\n', size(P,1)));

% name outputfile

% create mean
jp_log(meanlog, 'Creating mean...\n');
jp_spm_mean(P, struct('fname', outputname));
jp_log(meanlog, sprintf('done creating mean. Saved to %s.\n', outputname));

% done

