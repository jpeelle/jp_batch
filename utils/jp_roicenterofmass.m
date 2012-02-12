function com = jp_roicenterofmass(img, list)
%JP_ROICENTEROFMASS Find the XYZ coordinate at the 'center' of an ROI.
%
% JP_ROICENTEROFMASS(IMG) finds the mean location across all non-zero X,Y,
% and Z axes, in mm (using transformations from the image headers).  Result
% is rounded to the nearest mm.
%
% If IMG is not specified, you are prompted to select one ore more images.
%
% JP_ROICENTEROFMASS(IMG, LIST) will print a list of images and coordinates
% to the display window.
%
% JP_ROICENTEROFMASS depends on some helper functions from recent versions
% of SPM.

% Jonathan Peelle
% University of Pennsylvania

if nargin < 2 || isempty(list)
  list = 0;
end

if nargin < 1 || isempty(img)
  img = spm_select(Inf, 'Image');
end


% make sure img is in the expected format (e.g., if passed as cell array)
if iscell(img)
  img = strvcat(img);
end

nimg = size(img,1); % how many images?
com = zeros(nimg,3); % hold all centers of mass

for i=1:nimg
  com(i,:) = findcom(deblank(img(i,:)));

  if list > 0
    fprintf('%s:\t%4i\t%4i\t%4i\n', img(i,:), com(i,1), com(i,2), com(i,3));
  end
end

if list > 0
  fprintf('\n\n');
end


end % main function


function com = findcom(img)

V = spm_vol_nifti(img);
[Y, XYZ] = spm_read_vols(V);
Y = reshape(Y, 1, numel(Y));

% Only look at indices for non-zero voxels
x = Y>0;

% If no nonzeros voxels, warn, otherwise, take mean of what was found.
if sum(x)==0
  fprintf('Warning: No voxels > 0 in image %s.\n', img);
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

end % findcom subfunction