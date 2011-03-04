function cfg = jp_defaults_spmfmri(cfg)
%JP_DEFAULTS_SPMFMRI Default values for all JP_SPM functions.

% If no exisiting cfg, make a blank one
if nargin < 1
  cfg = struct();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General and misc functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg.options.max4d = 2000; % i.e. spm_select('ExtFpList', 'dir','^f', 1:cfg.options.max4d)

cfg.options.spmdefaultsfunction = 'spm_defaults';
cfg.options.dartelname = 'dartel';
cfg.options.mriext = 'nii'; % nii | img  % ** not implemented yet! this doesn't do anything. **



% For all values, normal SPM defaults are listed first, then a
% break, then any additional defaults.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPM 8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% SPM8 movefirstscans
%-----------------------------------------------------------------------

cfg.jp_spm8_movefirstscans.numscans = 4; % move this many
cfg.jp_spm8_movefirstscans.prefix = '';  % anything before funprefix



% SPM8 meanfunctionalpersession
%-----------------------------------------------------------------------
cfg.jp_spm8_meanfunctionalpersession.prefix = '';   % maybe s10w?
cfg.jp_spm8_meanfunctionalpersession.meanname = ''; % default [session]mean



% SPM8 tsdiffana
%-----------------------------------------------------------------------

cfg.jp_spm8_tsdiffana = [];


% SPM8 Realignment
%-----------------------------------------------------------------------

cfg.jp_spm8_realign.estimate.quality = 0.95; 
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



% SPM8 Reslice only
%-----------------------------------------------------------------------

cfg.jp_spm8_reslice.write = cfg.jp_spm8_realign.write;
cfg.jp_spm8_reslice.prefix = '';




% SPM8 first level mask
%-----------------------------------------------------------------------

cfg.jp_spm8_firstlevelmask.maskname = 'firstlevelmask.nii';  % mask saved in subject's directory with this name
cfg.jp_spm8_firstlevelmask.prefix = 'r';                     % assuming images have to be resliced to be in alignment



% SPM8 brain mask
%-----------------------------------------------------------------------

cfg.jp_spm8_brainmasksubject.thresh = .2; % (GM+WM)>thresh get included in mask
cfg.jp_spm8_brainmasksubject.maskname = 'brainmask.nii';



% SPM8 get bad scans
%-----------------------------------------------------------------------

% (these values 3.5 standard deviations from the mean for ~160
% subjects, so they seem like a good starting point)

cfg.jp_spm8_getbadscans.trans_x = .084;
cfg.jp_spm8_getbadscans.trans_y = .275;
cfg.jp_spm8_getbadscans.trans_z = .383;
cfg.jp_spm8_getbadscans.rot_x = .00657;
cfg.jp_spm8_getbadscans.rot_y = .00236;
cfg.jp_spm8_getbadscans.rot_z = .00195;
cfg.jp_spm8_getbadscans.timediff = 6.962;
cfg.jp_spm8_getbadscans.fname = 'jp_badscans.txt';


% SPM8 view_bad_scans
%-----------------------------------------------------------------------

% (use the same values as above)
cfg.jp_spm8_viewbadscans = cfg.jp_spm8_getbadscans;
cfg.jp_spm8_viewbadscans.ploteachsubject = 1;       % different plot for each subject



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



% SPM8 Coregister structural to template
%-----------------------------------------------------------------------

cfg.jp_spm8_coregisterstructural2template.move_functional = 1;
cfg.jp_spm8_coregisterstructural2template.functional_prefix = '';
cfg.jp_spm8_coregisterstructural2template.template = fullfile(spm('Dir'), 'canonical', 'avg152T1.nii');

cfg.jp_spm8_coregisterstructural2template.estimate = cfg.jp_spm8_coregister.estimate;
cfg.jp_spm8_coregisterstructural2template.write = cfg.jp_spm8_coregister.write;



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
cfg.jp_spm8_segment.estimate.samp     = 1;  % smaller should be more accurate (but take longer)
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
cfg.jp_spm8_segment8.samp = 1;                   % smaller should be more accurate (but take longer)
cfg.jp_spm8_segment8.writebiascorrected = [1 1]; % save bias corrected and field
cfg.jp_spm8_segment8.ngaus = [2 2 2 3 4 2];
cfg.jp_spm8_segment8.native = [1 1];             % native and DARTEL imported
cfg.jp_spm8_segment8.warped = [1 1];             % normalised modulated and unmodulated
cfg.jp_spm8_segment8.warpreg = 4;
cfg.jp_spm8_segment8.affreg = 'mni';
cfg.jp_spm8_segment8.bb = {ones(2,3)*NaN};
cfg.jp_spm8_segment8.vox = 1.5;
cfg.jp_spm8_segment8.writedeffields = [1 1];     % why not write them out

cfg.jp_spm8_segment8.biascorrectfirst = 1;       % write out bias corrected, then segment that
cfg.jp_spm8_segment8.segment8dir = '';           % if not empty, created within structural directory and output saved here



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



% SPM8 Normalize structural
%-----------------------------------------------------------------------


cfg.jp_spm8_normalizestructural.prefix = '';
cfg.jp_spm8_normalizestructural.write = cfg.jp_spm8_normalize.write;
cfg.jp_spm8_normalizestructural.write.vox = [1 1 1]; % keep high resolution for overlay



% SPM8 Smooth
%-----------------------------------------------------------------------

cfg.jp_spm8_smooth.fwhm = [];           % <-- needs to be set!
cfg.jp_spm8_smooth.prefix = 'w';



% SPM8 Model design
%-----------------------------------------------------------------------

cfg.jp_spm8_modeldesign.conditions = {};             % <-- needs to be set! See jp_spm8_modeldesign
cfg.jp_spm8_modeldesign.prefix = '';                 % <-- needs to be set!
cfg.jp_spm8_modeldesign.statsdir = '';               % <-- needs to be set!

cfg.jp_spm8_modeldesign.xM.TH = [];                  % these all set after spm_fmri_spm_ui is run
cfg.jp_spm8_modeldesign.xM.I = 0;
cfg.jp_spm8_modeldesign.xM.VM = [];

cfg.jp_spm8_modeldesign.T = 16;                      % (can be a vector, different for each session)
cfg.jp_spm8_modeldesign.T0 = 1;                      % (can be a vector, different for each session)
cfg.jp_spm8_modeldesign.event_units = 'secs';        % alternatively 'scans'
cfg.jp_spm8_modeldesign.bf_name = 'hrf';             % basis function used for analysis
cfg.jp_spm8_modeldesign.bf_length = 32;              % in seconds
cfg.jp_spm8_modeldesign.bf_order = 1;                % if needed by the basis function you choose
cfg.jp_spm8_modeldesign.global_normalization = 'None';
cfg.jp_spm8_modeldesign.highpass_cutoff = 90;
cfg.jp_spm8_modeldesign.autocorrelations = 'AR(1)';  % alternatively 'none'
cfg.jp_spm8_modeldesign.include_movement = 0;        % 1 = automatically adds movement parameters as regressors
cfg.jp_spm8_modeldesign.include_badscans = 0;        % 1 = add columns for bad scans (see jp_spm8_getbadscans)
cfg.jp_spm8_modeldesign.badscansfilename = cfg.jp_spm8_getbadscans.fname; % name of file containing bad scan numbers

cfg.jp_spm8_modeldesign.volterra = 1;
cfg.jp_spm8_modeldesign.fixemptyconditions = 1;      % if condition doesn't exist, add onset corresponding to last scan to keep # columns consistent

cfg.jp_spm8_modeldesign.evdir = 'ev_files';          % which directory to look in for EV files (event times), in each subject dir
cfg.jp_spm8_modeldesign.savedesignmatrix = 1;        % print a copy in the stats directory
cfg.jp_spm8_modeldesign.separatesessions = 0;        % if 1, separate GLM for each session (rare)



% SPM8 Model design for ISSS
%-----------------------------------------------------------------------
cfg.jp_spm8_ISSSmodeldesign = cfg.jp_spm8_modeldesign; % the same
cfg.jp_spm8_ISSSmodeldesign.pattern = [0 0 0 0 1 1 1 1 1 1 1]; % 0=dummy, 1=real
cfg.jp_spm8_ISSSmodeldesign.fillwithmean = 1; % select mean images for all 0s above
cfg.jp_spm8_ISSSmodeldesign.meanname = ''; % e.g., to match jp_spm8_meanfunctionalpersession



% SPM8 Estimate
%-----------------------------------------------------------------------
cfg.jp_spm8_modelestimate.separatesessions = cfg.jp_spm8_modeldesign.separatesessions;
cfg.jp_spm8_modelestimate.savemask = 1;                                           % print image of mask



% SPM8 DARTEL Create Template
%-----------------------------------------------------------------------
cfg.jp_spm8_dartelcreatetemplate.numtissues = 2;  % Generally 2
cfg.jp_spm8_dartelcreatetemplate.rform = 0;    

  

% SPM8 DARTEL Write MNI-normalized (structural)
%-----------------------------------------------------------------------
cfg.jp_spm8_dartelnormmnistruct.vox = 1.5;
cfg.jp_spm8_dartelnormmnistruct.fwhm = 8;         % smoothing (automatically done)
cfg.jp_spm8_dartelnormmnistruct.preserve = 1;
cfg.jp_spm8_dartelnormmnifun.otherimages = '';    % if specified, these files (assumed to be in subject's directory) are normalized as well


% SPM8 DARTEL Write MNI-normalized (functional)
%-----------------------------------------------------------------------

cfg.jp_spm8_dartelnormmnifun.vox = 2;
cfg.jp_spm8_dartelnormmnifun.fwhm = 10;           % smoothing (automatically done)
cfg.jp_spm8_dartelnormmnifun.preserve = 0;
cfg.jp_spm8_dartelnormmnifun.prefix = '';         % might be u if you've unwarped
cfg.jp_spm8_dartelnormmnifun.otherimages = '';    % if specified, these files (assumed to be in subject's directory) are normalized as well



% SPM8 Contrasts
%-----------------------------------------------------------------------

cfg.jp_spm8_contrasts.statsdir = '';           % <-- needs to be set!
cfg.jp_spm8_contrasts.which_contrasts = [];    % [] runs all

cfg.jp_spm8_contrasts.confiledirname = '@con_files';       % the @ puts it at the top of SPM search path
cfg.jp_spm8_contrasts.tandffiledirname = '@tandf_files';
cfg.jp_spm8_contrasts.separatesessions = 0;
cfg.jp_spm8_contrasts.badscanfilename = cfg.jp_spm8_getbadscans.fname;


% SPM8 DARTEL Write MNI-normalized (contrasts)
%-----------------------------------------------------------------------
cfg.jp_spm8_dartelnormmnicontrasts.statsdir = '';        % <-- needs to be set!
cfg.jp_spm8_dartelnormmnicontrasts.which_contrasts = [];
cfg.jp_spm8_dartelnormmnicontrasts.normmask = 1;         % 1 = norm mask also
cfg.jp_spm8_dartelnormmnicontrasts.vox = 2;
cfg.jp_spm8_dartelnormmnicontrasts.fwhm = 10;           % smoothing (automatically done)
cfg.jp_spm8_dartelnormmnicontrasts.preserve = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPM 5 (same as SPM8 unless changes required)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg.jp_spm5_tsdiffana = cfg.jp_spm8_tsdiffana;
cfg.jp_spm5_realign = cfg.jp_spm8_realign;
cfg.jp_spm5_realignunwarp = cfg.jp_spm8_realignunwarp;
cfg.jp_spm5_coregister = cfg.jp_spm8_coregister;
cfg.jp_spm5_segment = cfg.jp_spm8_segment;
cfg.jp_spm5_normalize = cfg.jp_spm8_normalize;
cfg.jp_spm5_normalizestructural = cfg.jp_spm8_normalizestructural;
cfg.jp_spm5_smooth = cfg.jp_spm8_smooth;
%cfg.jp_spm5_model = cfg.jp_spm8_model;
cfg.jp_spm5_contrasts = cfg.jp_spm8_contrasts;
