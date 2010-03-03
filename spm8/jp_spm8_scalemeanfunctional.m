function S = jp_spm8_scalemeanfunctional(S, subnum)
%JP_SPM8_MASKMEANFUNCTIONAL Make binary mask based on the mean.
%
% S = JP_SPM8_MASKMEANFUNCTIONAL(S, SUBNUM) uses the mean functional image created during realignment to create a binary mask based on proportional thresholding (of the mean signal over all voxels).  This is roughly comparable to the proportional masking implemented by spm_spm.
%
% This mask might be useful when normalizing using DARTEL, for example, in masking out non-brain voxels that get interpolated during the normalization process.
%
% The proportion used for masking is set in:
%
% S.cfg.jp_spm8_maskmeanfunctional.thresh (default .7).

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
[alllog, errorlog, masklog] = jp_createlogs(subname, S.subjdir, mfilename);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get mean functional image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jp_log(masklog, 'Looking for mean functional image...\n')

meanfun = spm_select('fplist', fullfile(subdir, fundirs{1}), sprintf('^mean%s%s.*\\.nii', cfg.prefix, funprefix));

if isempty(meanfun) || strcmp(meanfun, '/') || size(meanfun,1) ~= 1
  jp_log(errorlog, sprintf('Error finding mean functional image (found %s)', meanfun), 2);
elseif size(meanfun,1) > 1
  jp_log(errorlog, 'More than one mean functional image found.', 2);
end

jp_log(masklog, sprintf('Found %s.\n', meanfun));


[pth, nm, ext] = fileparts(meanfun);

jp_log(masklog, 'Reading in mean image...');
Vin = spm_vol(meanfun);
[Y, XYZ]= spm_read_vols(Vin);
jp_log(masklog, 'done.\n');
 
jp_log(masklog, 'Getting global value using spm_global...');
GX = spm_global(Vin);
jp_log(masklog, sprintf('done. Global mean is %.3f.\n', GX));
 
jp_log(masklog, 'Scaling mean image by global value...');
Ysc = Y / GX;
jp_log(masklog, 'done.\n');


jp_log(masklog, 'Writing scaled image...');
Vout = Vin;
Vout.fname = fullfile(pth, ['scaled' nm ext]);
Vout.descrip = 'mean image scaled by global - jp_spm8_scalemeanfunctional';
jp_log(masklog, 'done.\n');

