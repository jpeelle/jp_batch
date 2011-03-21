function jp_convertimg_tal2icbm(imgs)
% JP_CONVERTIMG_TAL2ICBM Convert images from T&T to ICBM(MNI) space.
%
%
% This is a combination of the BrainMAp tal2icbm_other function:
%   http://www.brainmap.org/icbm2tal/tal2icbm_other.m   
%
% and code from Matthew Brett:
%   https://cirl.berkeley.edu/mb312/icbm_transform/try_taling.m
%
% Use at your own risk! :)

% Jonathan Peelle
% University of Pennsylvania


% If no images specified, prompt for some
if nargin < 1 || isempty(imgs)
  imgs = spm_select(Inf, 'image', 'Select image(s) for transforming', [], pwd);
end

% Transformation matrices, different for each software package
icbm_other = [0.9357 0.0029 -0.0072 -1.0423
			 -0.0065 0.9396 -0.0726 -1.3940
			  0.0103 0.0752  0.8967  3.6475
			  0.0000 0.0000  0.0000  1.0000];

% invert the transformation matrix
icbm_other = inv(icbm_other);

% For each image, do the conversion
for i=1:size(imgs,1)
  fprintf('Converting image %i/%i...\n', i, size(imgs,1));
  
  % Get the current image and make it a volume
  G = deblank(imgs(i,:));
  [pth, nm, ext] = fileparts(G);
  VG = spm_vol(G);
  
  [R,C,P]=ndgrid(1:VG.dim(1),1:VG.dim(2),1:VG.dim(3));
  RCP = [R(:)';C(:)';P(:)'];
  RCP(4,:)=1;
  XYZ = VG.mat*RCP;

  % apply the transformation matrix to get a new list of coordinates
  nXYZ = VG.mat \ icbm_other * XYZ;
    
  % sample the image using the new XYZ coordinates
  img = spm_sample_vol(VG, nXYZ(1,:), nXYZ(2,:), nXYZ(3,:), 1);
  
  % create output file, and write it out
  VO = VG;
  VO.fname = fullfile(pth, [nm '_2icbm' ext]);  
  spm_write_vol(VO, reshape(img, VG.dim(1:3)));  
  
  fprintf('\tdone; saved to %s.\n', VO.fname);
end

fprintf('All done.\n');
