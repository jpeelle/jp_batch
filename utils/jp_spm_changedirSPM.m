function jp_spm_changedirSPM(files)
%JP_SPM_MOVESPM Change directory for SPM.mat files.
%
% JP_SPM_MOVESPM(SPM.mat_files) will change all of the paths in each
% SPM.mat file to the SPM.mat file's current location.
%
% JP_SPM_MOVESPM() will prompt you to select some SPM.mat files.
%
% This is to get around the fact that if you move a directory
% containing an SPM.mat file, viewing results gets complicated because
% the paths to the directory and images are stored in the SPM.mat file.
%
% The original SPM.mat file is saved as SPM.mat~.

% Jonathan Peelle
% MRC CBU
% November 2008


if nargin < 1
  files = spm_select(Inf, 'any', 'Select SPM.mat files', [], pwd, '^SPM\.mat$');
end


for i=1:size(files,1)
  fprintf('Changing directory for file %i/%i...', i, size(files,1));
  
  thisfile = files(i,:);

  % get the location/name of this file
  [pth, nm, ext] = fileparts(strtok(thisfile, ','));

  
  % load the SPM structure
  load(thisfile);
  
  % make a backup
  save([thisfile '~'], 'SPM');
  
  % get the old directory
  oldpth = SPM.swd;
  
  
  % The current location is what we are updating to; this is in pth. So
  % just find all the fields that have path information and replace
  % the old directory with the new one.
  SPM.swdir = pth;
  SPM.swd = pth;
  
  
  % save the updated SPM
  save(thisfile, 'SPM');
  
  % clear it
  clear SPM

  fprintf('done.\n');
end

fprintf('All done.\n');
