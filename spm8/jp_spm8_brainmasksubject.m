function S = jp_spm8_brainmasksubject(S, subnum)
%JP_SPM8_BRAINMASKSUBJECT Make a brainmask
%
% S = JP_SPM8_BRAINMASKSUBJECT makes a binary brainmask for a subject based on smoothed segmented structural images (for now, just from DARTEL).
%
% The threshold for binarizing is set in:
%
% S.cfg.jp_spm8_brainmasksubject.thresh (default .2)

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



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

if ischar(structdir)
  structdir = cellstr(structdir);
end

% log files
[alllog, errorlog, masklog] = jp_createlogs(subname, S.subjdir, mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NB assume smoothed normalized in S.cfg.options.dartelname
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tmpdir = fullfile(S.subjdir, subname, structdir{1}, S.cfg.options.dartelname);

jp_log(masklog, 'Looking for smoothed segmented images...');
imgs = [];
for k=1:2
  imgs = strvcat(imgs, spm_select('fplist', tmpdir, sprintf('smwrc%i.*nii', k)));  
end

if size(imgs,1)~=2
  jp_log(errorlog, sprintf('Not 2 images selected from %s.', tmpdir));
end

jp_log(masklog, 'found them.\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add images (automatically gets written)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jp_log(masklog, 'Adding images...');
VI = spm_vol(imgs);
VO = VI(1);
VO.fname = fullfile(S.subjdir, subname, cfg.maskname);
VO.descrip = 'jp_spm8_brainmasksubject';
VO = spm_add2(VI, VO);
jp_log(masklog, 'done.\n');


jp_log(masklog, 'Thresholding image...');
[Y, XYZ] = spm_read_vols(VO);
Y = Y >= cfg.thresh;
spm_write_vol(VO,Y);
jp_log(masklog, 'done.\n');
jp_log(masklog, sprintf('Mask saved to %s.\n', VO.fname));






