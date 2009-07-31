function S = jp_spm8_segment8(S, subnum)
%JP_SPM8_SEGMENT8 Segment images using 'new' SPM8 routine.
%
% S = JP_SPM8_SEGMENT8(S, SUBNUM) will segment the first structural
% image found in the first structural directory for SUBNUM from an
% S structure (see JP_INIT).
%
% See JP_DEFAULTS for a full list of options.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


%- first make sure spm_preproc8 is in the path, as a toolbox it
%might not be

if ~strcmp(spm('ver'),'SPM8')
    error('%s requires SPM8.', mfilename);
end

if ~exist('spm_preproc_run')
  try
    % try adding a likely location
    addpath(fullfile(spm('dir'),'toolbox','Seg'))
  catch
  end
end
if ~exist('spm_preproc_run')
  error('spm_preproc8 is not in your Matlab path but needs to be.')
end


% make sure optimNn is in the path, usually with DARTEL
if ~exist('optimNn')
    try
        addpath(fullfile(spm('dir'),'toolbox','DARTEL'))
    catch
    end
end
if ~exist('optimNn')
    error('optimNn is not in your Matlab path but needs to be.');
end




subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

% log files
[alllog, errorlog, seg8log] = jp_createlogs(subname, S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);



try
  structprefix = S.subjects(subnum).structprefix;
catch
  structprefix = jp_getinfo('structprefix', S.subjdir, subname);
end

try
  structdirs = S.subjects(subnum).structdirs;
catch
  structdirs = jp_getinfo('structdirs', S.subjdir, subname);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get structural image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jp_log(seg8log, sprintf('Looking for structural image in %s...\n', structdirs{1}));
img = jp_getstructimages(structprefix, S.subjdir, subname, structdirs{1});

if isempty(img) || strcmp(img, '/')
  jp_log(seg8log, 'Did not find any images.', 2);
elseif size(img,1) > 1
  img = img(1,:);
end

jp_log(seg8log, sprintf('Found %s.\n', img));
  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If bias-correct first, do that
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if cfg.biascorrectfirst
  fprintf('Initial bias correction...');
  
  estopts.samp = cfg.samp;
  estopts.regtype=''; % turn off affine
  p = spm_preproc(img, estopts);   
  [po,pin]   = spm_prep2sn(p);
  
  writeopts.biascor = 1;
  writeopts.GM  = [0 0 0];
  writeopts.WM  = [0 0 0];
  writeopts.CSF = [0 0 0];
  writeopts.cleanup = 0;
  spm_preproc_write(po, writeopts);
  
  [pth, nam, ext] = fileparts(img);
  bcout = fullfile(pth,['m' nam ext]);        
  img = bcout;
  
  fprintf('done.\n');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set obj structure to pass to spm_preproc8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


jp_log(seg8log, 'Configuring segmentation job...');

% tissue argument
% (complicated but seems the best way...copied from the tbx_cfg_preproc8 script)


%tissue(1).tpm = cfg.tpm;
%tissue(1).ngaus = cfg.ngaus;
%tissue(1).native = cfg.native;
%tissue(1).warped = cfg.warped;

% Every tissuce class needs a map name, number of gaussians, and nval?

tpm_nam = cfg.tpm;
ngaus   = cfg.ngaus;
nval    = {[1 0],[1 0],[1 0],[1 0],[1 0],[0 0]};
for k=1:length(ngaus)
    tissue(k).tpm = [tpm_nam ',' num2str(k)]; % assign the tpm map
    tissue(k).ngaus = ngaus(k);  % and the number of gaussians
    tissue(k).native = cfg.native;
    tissue(k).warped = cfg.warped;
   % tissue.val{3}.val    = {nval{k}};   % and whatever this is
end

job.channel(1).vols{1} = img;
job.channel(1).biasreg = cfg.biasreg;
job.channel(1).biasfwhm = cfg.biasfwhm;
job.channel(1).write = cfg.writebiascorrected;
job.channel(1).tpm = cfg.tpm;
job.channel(1).ngaus = cfg.ngaus;
job.channel(1).native = cfg.native;
job.channel(1).warped = cfg.warped;

job.tissue = tissue;

job.warp.affreg = cfg.affreg;
job.warp.reg = cfg.warpreg;
job.warp.samp = cfg.samp;
job.warp.write = cfg.writedeffields;
job.warp.bb = cfg.bb;
job.warp.vox = cfg.vox;

jp_log(seg8log, 'done.\n');


% be nice and remind user this might take a while
if cfg.samp < 2
  fprintf('Note that cfg.samp is relatively small, which may take quite a while to run.\n');
end


% save job in case we want to inspect later
S.subjects(subnum).(mfilename).job = job;

jp_log(seg8log, 'Starting segmentation8...\n');
spm_preproc_run(job);
jp_log(seg8log, 'Done with segmentation8.\n');






