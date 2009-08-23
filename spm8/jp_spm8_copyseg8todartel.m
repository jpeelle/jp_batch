function S = jp_spm8_copyseg8todartel(S, subnum)
%JP_SPM8_COPYSEG8TODARTEL Prepare to use segmented images for DARTEL.
%
% S = JP_SPM8_COPYSEG8TODARTEL(S, SUBNUM) will make links to
% segmented images from within a DARTEL directory
% (S.cfg.options.dartelname) to the structural directory. Usually
% this is preceded by JP_SPM8_SEGMENT8 and followed with
% JP_SPM8_DARTELCREATETEMPLATE.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

% log files
[alllog, errorlog, copylog] = jp_createlogs(subname, S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);


% DARTEL directory
structdir = fullfile(subdir, S.subjects(subnum).structdirs{1});
darteldir = fullfile(structdir, S.cfg.options.dartelname);

if ~isdir(darteldir)
  mkdir(darteldir);
end
  
% get all the rc* images from the seg8dir
rcimages = spm_select('fplist', structdir, '^rc.*\.nii');

for i=1:size(rcimages,1)
  img = strtok(rcimages(i,:)); % get this image
  jp_log(copylog, sprintf('Creating softlink to %s...', img));
  [pth, nm, ext] = fileparts(img);
  system(sprintf('ln -s %s %s', img, fullfile(darteldir,[nm ext])));
  jp_log(copylog, sprintf('done.\n'));
end


