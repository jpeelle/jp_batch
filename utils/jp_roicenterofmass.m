function com = jp_roicenterofmass(img)
%JP_ROICENTEROFMASS Find the XYZ coordinate at the 'center' of an ROI.
%
% JP_ROICENTEROFMASS(IMG) finds the mean location across all non-zero X,Y,
% and Z axes, in mm (using transformations from the image headers).  Result
% is rounded to the nearest mm.
%
% JP_ROICENTEROFMASS depends on some helper functions from recent versions
% of SPM.

% Jonathan Peelle
% University of Pennsylvania

if nargin < 1 || isempty(img)
  img = spm_select(1, 'Image');
end

V = spm_vol_nifti(img);
[Y, XYZ] = spm_read_vols(V);
Y = reshape(Y, 1, numel(Y));

% Only look at indices for non-zero voxels
x = Y>0;

if sum(x)==0
  fprintf('Warning: No voxels > 0 in image.');
  com = nan(1,3);
else
  XYZx = XYZ(:,Y>0);
  % Center of mass = mean across X, Y, Z directions.
  com = round(mean(XYZx,2));
end

% Ensure 1x3 coordinate
if size(com,1)==3
  com = com';
end