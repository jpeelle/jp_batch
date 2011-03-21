function S = jp_spm8_dartelnormmnicontrasts(S)
%JP_SPM8_DARTELNORMMNICONTRASTS Write MNI functional images.
%
% S = JP_SPM8_DARTELNORMMNICONTRASTS(S) will write MNI-normalized
% contrast images following the creation of a DARTEL template.
%
% Note that this function also does Gaussian smoothing (default 10
% mm FWHM).
%
% This must be run on the study level; i.e.:
%
%  S = jp_addanalysis(S, 'jp_spm8_dartelnormmnicontrasts', 'study');
%
% The default voxel size is 2 x 2 x 2.
%
% This also warps smoothed versions of the mask.img file to the contrast file directory.
%
% See JP_DEFAULTS_SPMFMRI for a full list of defaults.

% Jonathan Peelle
% University of Pennsylvania


% log files
[alllog, errorlog, normlog] = jp_createlogs('', S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);

subjdir = S.subjdir;
statsdir = cfg.statsdir;
od = pwd;

% get contrasts
cd(statsdir);
c = contrasts(zeros(1,100));
cd(od);


if isempty(cfg.which_contrasts)
  cfg.which_contrasts = 1:length(c);
end


jp_log(normlog, sprintf('Using %s.\n', which('spm_dartel_norm_fun')));

% Where are the templates?
templatedir = fullfile(S.subjdir, sprintf('templates_%s', S.cfg.options.dartelname));
template = spm_select('fplist', templatedir, '^Template_6\.nii$');

if isempty(template) || strcmp(template, '/')
  jp_log(normlog, 'Could not find Template6.nii.', 2);
end

% Get images
allimages = {};
for s=1:length(S.subjects)
  imgs = [];
  
  subname = S.subjects(s).name;
  
  jp_log(normlog, sprintf('Getting flowfields and images for subject %s...\n', S.subjects(s).name));
  
  darteldir = fullfile(S.subjdir, S.subjects(s).name, S.subjects(s).structdirs{1}, S.cfg.options.dartelname);
  
  % flow fields
  job.data.subj(s).flowfield{1} = spm_select('fplist', darteldir, '^u.*nii');
  
  % images
  prefix = 'con';

  substatdir = fullfile(cfg.statsdir, subname);


  for w=1:length(cfg.which_contrasts)
    imgs = strvcat(imgs, spm_select('fplist', substatdir, sprintf('^con_%04i\\.img', cfg.which_contrasts(w))));
  end
  
  if cfg.normmask > 0
    jp_log(normlog, 'Adding mask image...');
    imgs = strvcat(imgs, spm_select('fplist', substatdir, '^mask\.img$'));
    jp_log(normlog, 'done.\n');
  end
  
  if isempty(imgs) || strcmp(imgs, '/')
    jp_log(errorlog, sprintf('No images found for subject %s.', S.subjects(s).name), 2);
  end
  
  if cfg.normmask > 0  
    jp_log(normlog, sprintf('\t%i contrast images (including 1 mask image) found.\n', size(imgs,1)));
  else
    jp_log(normlog, sprintf('\t%i contrast images found.\n', size(imgs,1)));
  end
  
  job.data.subj(s).images = cellstr(imgs);
end % going through subjects

% set up the job
jp_log(normlog, 'Setting up normalization job...');

job.template{1} = template;
job.bb = nan(2,3);
job.vox = ones(1,3) * cfg.vox;
job.fwhm = cfg.fwhm;
job.preserve = cfg.preserve;

jp_log(normlog, 'done.\n');

jp_log(normlog, 'Registering to MNI, then normalizing each subject:\n\n');
spm_dartel_norm_fun(job);


% softlink images in new @con file directory
fprintf('Making softlinks to contrast images and mask images...\n');

try
  condirname = S.cfg.jp_spm8_contrasts.confiledirname;
catch
  condirname = '@con_files';
end

if cfg.normmask > 0
  maskdir = fullfile(statsdir, '@masks');
  if ~isdir(maskdir)
    mkdir(fix_string(maskdir));
  end
end

%try
  for s=1:length(S.subjects)
    
    jp_log(normlog, sprintf('Subject %i/%i...', s, length(S.subjects)));
    
    subname = S.subjects(s).name;
    condir = fullfile(cfg.statsdir, subname);
    
    for w = 1:length(cfg.which_contrasts) 
     
      
      this_c = cfg.which_contrasts(w);      
      cdir = fullfile(statsdir,[fix_string(condirname) '_normalized'],fix_string(c(this_c).name));
      
      if ~isfield(c, 'STAT') || isempty(c(this_c).STAT)
        c(this_c).STAT = 'T';
      end
      
      
      % fix_string makes string suitable for passing to system because it
      % preprents a \ to each > sign, for example.  But this isn't good for
      % Matlab functions like isdir and mkdir.  The goodfordir function
      % removes backslashes from the string. 
      
      if ~exist(goodfordir(cdir)); mkdir(goodfordir(cdir)); end
    
      %[pth, condir_local] = fileparts(cdir);
    
      if strcmp(c(this_c).STAT,'T')
        system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('swcon_%04i.img',this_c)), fullfile(cdir,sprintf('%s_swcon_%04i.img',subname,this_c))));
        system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('swcon_%04i.hdr',this_c)), fullfile(cdir,sprintf('%s_swcon_%04i.hdr',subname,this_c))));
      else
        system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('swess_%04i.img',this_c)), fullfile(cdir,sprintf('%s_swess_%04i.img',subname,this_c))));
        system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('swess_%04i.hdr',this_c)), fullfile(cdir,sprintf('%s_swess_%04i.hdr',subname,this_c))));
      end
    end    
    
    % binarize the mask
    if cfg.normmask > 0
      maskimg = fullfile(condir, 'swmask.img');
      maskoutimg = fullfile(condir, 'binarized_swmask.nii');
      
      Vi = spm_vol(maskimg);
      Vo = Vi;
      Vo.fname = maskoutimg;
      f = 'i1>0';
      Vo = spm_imcalc(Vi, Vo, f, []);
            
      % softlink
      system(sprintf('ln -sf %s %s', maskoutimg, fullfile(maskdir, sprintf('%s_binarized_swmask.nii', subname))));
    end
    
    fprintf('done.\n');
  end % going through subjects
% catch
%   fprintf('ERROR: There was an error making the softlinks to the con* files.\n');
% end



% make a conjunction mask of all the subjects' masks
if cfg.normmask > 0
  jp_log(normlog, 'Creating conjunction mask of all subject masks...\n');
  
  imgs = spm_select('fplist', maskdir, '.*swmask.nii$');
  
  % can just use volume from last subject
  Vo.fname = fullfile(maskdir, 'groupmask.nii');
  Vi = spm_vol(imgs);
  Vo = spm_imcalc(Vi, Vo, 'mean(X)==1', {1});
  
  jp_log(normlog, 'done.\n');
end



jp_log(normlog, 'All done.\n');

end

function new_string = fix_string(s)
new_string = strrep(s,' ','_');
new_string = strrep(new_string,'>','\>');
new_string = strrep(new_string,'<','\<');
new_string = strrep(new_string,'(','_');
new_string = strrep(new_string,')','_');
new_string = strrep(new_string, '@', '\@');
end % fix_string

function new_string = goodfordir(s)
new_string = strrep(s, '\', '');
end
