function S = jp_spm5_segmentimage(images, cfg);
%JP_SPM5_SEGMENTIMAGE Segment images.
%
% JP_SPM5_SEGMENTIMAGE(IMAGES,CFG)
%
% Options for CFG are in JP_SPM5_SEGMENT and JP_DEFAULTS.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


if nargin < 1 || isempty(images)
  images = spm_select(Inf, 'image', 'Select images to segment');
  if isempty(images)
      error('You must specify some images.')
  end
end

if nargin < 2
  cfg = struct();
end

cfg = jp_setcfg(cfg, 'jp_spm5_segment'); % same defaults


if ischar(images)
  images = cellstr(images);
end

% get rid of spaces
for i=1:length(images)
  images{i} = strtok(images{i}, ' ');
end

% get estimation options
estopts = cfg.estimate;

for i=1:length(images)
  im = images{i};
  
  if ~exist(im)
    error('%s not found.', im);
  end
  
  
  if cfg.biascorrectfirst
    fprintf('Initial bias correction...');
    
    estopts.regtype=''; % turn off affine
    p = spm_preproc(im, estopts);   
    [po,pin]   = spm_prep2sn(p);
    
    writeopts.biascor = 1;
    writeopts.GM  = [0 0 0];
    writeopts.WM  = [0 0 0];
    writeopts.CSF = [0 0 0];
    writeopts.cleanup = 0;
    spm_preproc_write(po, writeopts);
    
    [pth, nam, ext] = fileparts(im);
    bcout = fullfile(pth,['m' nam ext]);        
    im = bcout;
    
    fprintf('done.\n');
  end % checking for biascorrect first
  
  writeopts = cfg.write;

  if cfg.biascorrectfirst
    writeopts.biascor = 0; % if already did, don't do again
  end

  estopts = cfg.estimate; % reset
  
  fprintf('Segmenting...');
  p = spm_preproc(im, estopts);
  [po, pin] = spm_prep2sn(p);
  spm_preproc_write(po,writeopts);  
  [pth, nam, ext] = fileparts(im);
  savefields(fullfile(pth, [nam '_seg_sn.mat']),po);
  savefields(fullfile(pth, [nam '_seg_inv_sn.mat']),pin);       
  fprintf('done.\n');
  
  
end % going through images

end % main function



%------------------------------------------------------------------------
function savefields(fnam,p)  % from spm_config_preproc
if length(p) > 1, error('Can''t save fields.'); end
fn = fieldnames(p);
if numel(fn)==0; return; end
for i=1:length(fn),
  eval([fn{i} '= p.' fn{i} ';']);
end
if spm_matlab_version_chk('7') >= 0
  save(fnam,'-V6',fn{:});
else
  save(fnam,fn{:});
end
end % savefields


