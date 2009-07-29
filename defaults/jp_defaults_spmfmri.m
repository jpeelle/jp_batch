function cfg = jp_defaults_spmfmri(cfg)
%JP_DEFAULTS_SPMFMRI Default values for all JP_SPM functions.

% If no exisiting cfg, make a blank one
if nargin < 1
  cfg = struct();
end


% For all values, normal SPM defaults are listed first, then a
% break, then any additional defaults.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPM 8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% SPM8 Realignment
%-----------------------------------------------------------------------

cfg.jp_spm8_realign.estimate.quality = 0.93; 
cfg.jp_spm8_realign.estimate.weight  = 0;
cfg.jp_spm8_realign.estimate.interp  = 2;
cfg.jp_spm8_realign.estimate.wrap    = [0 0 0];
cfg.jp_spm8_realign.estimate.sep     = 4;
cfg.jp_spm8_realign.estimate.fwhm    = 5;
cfg.jp_spm8_realign.estimate.rtm     = 1;
cfg.jp_spm8_realign.write.mask       = 1;
cfg.jp_spm8_realign.write.interp     = 4;
cfg.jp_spm8_realign.write.wrap       = [0 0 0];

cfg.jp_spm8_realign.prefix = '';
cfg.jp_spm8_realign.which_images     = 0;    % 0 = mean only, 2 = all




% SPM8 Realign & Unwarp
%-----------------------------------------------------------------------

cfg.jp_spm8_realignunwarp.prefix = '';       % maybe 'r' if you resliced during realignment



% SPM8 Coregister
%-----------------------------------------------------------------------

cfg.jp_spm8_coregister.estimate.cost_fun = 'nmi';
cfg.jp_spm8_coregister.estimate.sep      = [4 2];
cfg.jp_spm8_coregister.estimate.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
cfg.jp_spm8_coregister.estimate.fwhm     = [7 7];
cfg.jp_spm8_coregister.write.interp      = 1;
cfg.jp_spm8_coregister.write.wrap        = [0 0 0];
cfg.jp_spm8_coregister.write.mask        = 0;

cfg.jp_spm8_coregister.prefix            = '';   % used for finding mean functional image



% SPM8 Segment [estimate options passed to spm_preproc]
%-----------------------------------------------------------------------


cfg.jp_spm8_segment.estimate.tpm   = char(...
               fullfile(spm('Dir'),'tpm','grey.nii'),...
               fullfile(spm('Dir'),'tpm','white.nii'),...
               fullfile(spm('Dir'),'tpm','csf.nii'));
cfg.jp_spm8_segment.estimate.ngaus    = [2 2 2 4];
cfg.jp_spm8_segment.estimate.warpreg  = 1;
cfg.jp_spm8_segment.estimate.warpco   = 25;
cfg.jp_spm8_segment.estimate.biasreg  = 0.0001;
cfg.jp_spm8_segment.estimate.biasfwhm = 75;
cfg.jp_spm8_segment.estimate.regtype  = 'mni';
cfg.jp_spm8_segment.estimate.fudge    = 5;
cfg.jp_spm8_segment.estimate.samp     = 3;
cfg.jp_spm8_segment.estimate.msk      = '';

cfg.jp_spm8_segment.write.biascor = 1;       % whether to biascorrect (turned off if biascorrectfirst)
cfg.jp_spm8_segment.write.GM      = [1 1 1]; % [1 1 1] = output all images (native/normalized modulated/unmodulated)
cfg.jp_spm8_segment.write.WM      = [1 1 1];
cfg.jp_spm8_segment.write.CSF     = [1 1 1];
cfg.jp_spm8_segment.write.cleanup = 0;

cfg.jp_spm8_segment.biascorrectfirst = 1;    % write out bias corrected, then segment that



% SPM8 Segment8 [estimate options passed to spm_preproc8 in obj,
% see also cfg_tbx_preproc8.m and spm_config_preproc8]
%-----------------------------------------------------------------------

cfg.jp_spm8_segment8.biasfwhm = 60;
cfg.jp_spm8_segment8.biasreg = .0001;
cfg.jp_spm8_segment8.tpm = fullfile(spm('dir'), 'toolbox', 'Seg', 'TPM.nii');
cfg.jp_spm8_segment8.lkp = [1,1,2,2,3,3,4,4,4,5,5,5,5,6,6];
cfg.jp_spm8_segment8.reg = .001;
cfg.jp_spm8_segment8.samp = 2; % sampling distance; default is 3, assuming 2 is a little more accurate
cfg.jp_spm8_segment8.writebiascorrected = [1 1]; % save bias corrected and field
cfg.jp_spm8_segment8.ngaus = [2 2 2 3 4 2];
cfg.jp_spm8_segment8.native = [1 1]; % native and DARTEL imported
cfg.jp_spm8_segment8.warped = [1 1]; % normalised modulated and unmodulated
cfg.jp_spm8_segment8.warpreg = 4;
cfg.jp_spm8_segment8.affreg = 'mni';
cfg.jp_spm8_segment8.bb = {ones(2,3)*NaN};
cfg.jp_spm8_segment8.vox = 1.5;
cfg.jp_spm8_segment8.writedeffields = [1 1]; % why not write them out

cfg.jp_spm8_segment8.biascorrectfirst = 1; % write out bias corrected, then segment that




% SPM8 Normalize
%-----------------------------------------------------------------------

cfg.jp_spm8_normalize.estimate.smosrc  = 8;
cfg.jp_spm8_normalize.estimate.smoref  = 0;
cfg.jp_spm8_normalize.estimate.regtype = 'mni';
cfg.jp_spm8_normalize.estimate.weight  = '';
cfg.jp_spm8_normalize.estimate.cutoff  = 25;
cfg.jp_spm8_normalize.estimate.nits    = 16;
cfg.jp_spm8_normalize.estimate.reg     = 1;
cfg.jp_spm8_normalize.estimate.wtsrc   = 0;
cfg.jp_spm8_normalize.write.preserve   = 0;    % 1 = modulate, 0 = don't modulate
cfg.jp_spm8_normalize.write.bb         = [[-78 -112 -50];[78 76 85]];
cfg.jp_spm8_normalize.write.vox        = [2 2 2];
cfg.jp_spm8_normalize.write.interp     = 1;
cfg.jp_spm8_normalize.write.wrap       = [0 0 0];

cfg.jp_spm8_normalize.prefix = '';      % prefix for functional images to be selected




% SPM8 Smooth
%-----------------------------------------------------------------------

cfg.jp_spm8_smooth.fwhm = [];           % <-- needs to be set!
cfg.jp_spm8_smooth.prefix = 'w';



% SPM8 Model
%-----------------------------------------------------------------------

cfg.jp_spm8_model.conditions = [];             % <-- needs to be set!
cfg.jp_spm8_model.imageprefix = '';            % <-- needs to be set!
cfg.jp_spm8_model.statsdir = '';               % <-- needs to be set!

cfg.jp_spm8_model.xM.TH = [];                  % these all set after spm_fmri_spm_ui is run
cfg.jp_spm8_model.xM.I = 0;
cfg.jp_spm8_model.xM.VM = {[]};

cfg.jp_spm8_model.separatesessions = 0;        % if 1, separate GLM for each session (rare)
cfg.jp_spm8_model.T = 16;                      % (can be a vector, different for each session)
cfg.jp_spm8_model.T0 = 1;                      % (can be a vector, different for each session)
cfg.jp_spm8_model.event_units = 'secs';        % alternatively 'scans'
cfg.jp_spm8_model.bf_name = 'hrf';             % basis function used for analysis
cfg.jp_spm8_model.bf_length = 32;              % in seconds
cfg.jp_spm8_model.bf_order = 1;                % if needed by the basis function you choose
cfg.jp_spm8_model.global_normalization = 'None';
cfg.jp_spm8_model.highpass_cutoff = 90;
cfg.jp_spm8_model.autocorrelations = 'AR(1)';  % alternatively 'none'
cfg.jp_spm8_model.include_movement = 0;        % 1 = automatically adds movement parameters as regressors
cfg.jp_spm8_model.volterra = 1;
cfg.jp_spm8_model.fixemptyconditions = 1;      % if condition doesn't exist, add onset corresponding to last scan to keep # columns consistent

cfg.jp_spm8_model.evdir = 'ev_files';          % which directory to look in for EV files (event times), in each subject dir


% SPM8 Contrasts
%-----------------------------------------------------------------------

cfg.jp_spm8_contrasts.statsdir = '';           % <-- needs to be set!
cfg.jp_spm8_contrasts.which_contrasts = [];    % [] runs all

cfg.jp_spm8_contrasts.confiledirname = '@con_files';       % the @ puts it at the top of SPM search path
cfg.jp_spm8_contrasts.tandffiledirname = '@tandf_files';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPM 5 (same as SPM8 unless changes required)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg.jp_spm5_realign = cfg.jp_spm8_realign;
cfg.jp_spm5_realignunwarp = cfg.jp_spm8_realignunwarp;
cfg.jp_spm5_coregister = cfg.jp_spm8_coregister;
cfg.jp_spm5_segment = cfg.jp_spm8_segment;
cfg.jp_spm5_normalize = cfg.jp_spm8_normalize;
cfg.jp_spm5_smooth = cfg.jp_spm8_smooth;
cfg.jp_spm5_model = cfg.jp_spm8_model;
cfg.jp_spm5_contrasts = cfg.jp_spm8_contrasts;
