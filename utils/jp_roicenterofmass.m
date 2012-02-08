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

V = spm_vol_nifti(img);
[Y, XYZ] = spm_read_vols(V);
Y = reshape(Y, 1, numel(Y));

% Find the indices for all non-zero voxels
x = find(Y>0);

% Only look at those indices
XYZx = XYZ(:,x);

% Center of mass = mean across X, Y, Z directions.
com = round(mean(XYZx,2)');