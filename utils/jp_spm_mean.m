function jp_spm_mean(P, cfg)
%JP_SPM_MEAN Get the mean of some images, optionally threshold.
%
% JP_SPM_MEAN(P,CFG) takes the mean of images in P using options in
% CFG. If P is not specified, prompts for GUI selection.
%
%
% This is based largely of of spm_mean_ui and should work in
% SPM5/8. Modified to include thresholding and various options.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit

if nargin < 2
  cfg = [];
end

if ~isfield(cfg, 'fname')
  cfg.fname = 'mean.nii';
end

if nargin < 1 || isempty(P)
  P = spm_select(Inf, 'image', 'Select images to be averaged');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next parts are from spm_mean_ui
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf('Mapping files...');
Vi = spm_vol(P);
fprintf('done.\n');

fprintf('Checking files...');
spm_check_orientations(Vi);
fprintf('done.\n');

n  = prod(size(Vi));
if n==0, fprintf('\t%s : no images selected\n\n',mfilename), return, end


%-Compute mean and write headers etc.
%-----------------------------------------------------------------------
fprintf('Computing mean...\n')
Vo = struct(    'fname',    cfg.fname,...
        'dim',      Vi(1).dim(1:3),...
        'dt',           [4, spm_platform('bigend')],...
        'mat',      Vi(1).mat,...
        'pinfo',    [1.0,0,0]',...
        'descrip',  'spm - mean image');

%-Adjust scalefactors by 1/n to effect mean by summing
for i=1:prod(size(Vi))
  Vi(i).pinfo(1:2,:) = Vi(i).pinfo(1:2,:)/n;
end

Vo = spm_create_vol(Vo);
Vo.pinfo(1,1) = spm_add(Vi,Vo);
Vo = spm_create_vol(Vo);

fprintf('done.\n');

fprintf('Image written to %s.\n', cfg.fname);
