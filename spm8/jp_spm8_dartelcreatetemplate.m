function S = jp_spm8_dartelcreatetemplate(S);
%JP_SPM8_DARTELCREATETEMPLATE Create a template using DARTEL.
%
% S = JP_SPM8_DARTELCREATETEMPLATE(S) takes all of the segmented
% registered images (rc*) and creates a template for all subjects
% in an S structure (see JP_INIT).
%
% The default values are geared towards assuming you've segmented
% images using JP_SPM8_SEGMENT8.
%
% See JP_DEFAULTS for a full list of options.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


% log files
[alllog, errorlog, templatelog] = jp_createlogs('', S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);

jp_log(templatelog, sprintf('Using %s.\n', which('spm_dartel_template')));

for s = 1:length(S.subjects)
  subname = S.subjects(s).name;
  subdir = fullfile(S.subjdir, subname);
  darteldir = fullfile(subdir, S.subjects(s).structdirs{1}, S.darteldir);
  
  jp_log(templatelog, sprintf('Getting images for subject %s...\n', subname));
  
  for k=1:cfg.numtissues
    imgs = spm_select('fplist', darteldir, sprintf('^rc%d.*nii',k));
    
    % Note any subjects for which we couldn't find an image
    if isempty(imgs) || strcmp(imgs, '/')
      jp_log(errorlog, sprintf('No rc* images found for subject %s.\n', subname), 2);
    elseif (size(imgs,1)~=1)
      jp_log(errorlog,sprintf('Did not find exactly 1 rc%d image in %s',k,darteldir), 2);
    end
    
    allimages{k}{s}=imgs;
  end % going through tissue classes
  
  jp_log(templatelog, 'done.\n');
end % going through subjects




% Set up job
% below based on tbx_cfg_dartel 15 July 2009
% eventually these should probably be user-definable

jp_log(templatelog, 'Setting up job...');

param = struct(...
    'its',{3,3,3,3,3,3},...
    'rparam',{[4 2 1e-6],[2 1 1e-6],[1 0.5 1e-6],...
              [0.5 0.25 1e-6],[0.25 0.125 1e-6],[0.25 0.125 1e-6]},...
    'K',{0,0,1,2,4,6},...
    'slam',{16,8,4,2,1,0.5});

settings = struct('template','Template','rform',cfg.rform,...
                  'param',param,...
                  'optim', struct('lmreg',0.01, 'cyc', 3, 'its', 3));



job = struct('images',{allimages}, 'settings',settings);

jp_log('done.\n');

% run the script
jp_log(templatelog, 'Starting job (this can take a while)...\n');
spm_dartel_template(job);
jp_log(templatelog, 'done.\n');


% Make a folder in the main study directory to hold templates
templatedir = fullfile(S.subjdir, sprintf('templates_%s', S.darteldir));
if ~isdir(templatedir)
  jp_log(templatelog, sprintf('Creating %s...', templatedir));
  mkdir(templatedir);
  jp_log(templatelog, 'done.\n');
end


firstdir = fullfile(S.subjdir, S.subjects(1).name, S.subjects(1).structdirs{1}, S.darteldir);

try
  jp_log(templatelog, sprintf('Moving templates from %s to %s...', firstdir, templatedir));
  system(sprintf('mv %s/Template*.nii %s/', firstdir, templatedir));
  jp_log(templatelog, 'done.\n');
catch
  jp_log(templatelog, sprintf('WARNING: Error moving templates to %s, but everything else should be ok.\n', templatedir));  
end

