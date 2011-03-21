function S = jp_spm8_specify1stlevel(S, subnum)
%JP_SPM8_SPECIFY1STLEVEL Design first-level model with SPM8.
%
% S = JP_SPM8_SPECIFY1STLEVEL(S, SUBNUM) constructs a first level model on the
% specified subject number SUBNUM from an S structure (see
% JP_INIT).
%
% The analysis options are set in S.cfg.jp_spm8_model and include:
%  conditions        names of your conditions (see below)
%  prefix            prefix of images that are selected (maybe 'sw')
%  separatesessions  analyze each session in a different model (see below)
%
%  event_units   default 'secs'
%  bf_name       default 'hrf'
%  bf_length     default 32
%  bf_order      default 1 (if required by bf_name)
%  global_normalization   default 'None'
%  highpass_cutoff        default 90
%  autocorrelations       default 'AR(1)' (other option is 'none')
%  include_movement       default 0 (1 to include rp_*.txt as covariate)
%  include_badscans       default 0 (1 to include bad scans as additional columns)
%  volterra               default 1
%  T                      number of time bins, used for SPM.xBF.T (default 16)
%  T0                     which regressors are sampled at, used for SPM.xBF.T0 (default 1)
%
%
% Each condition you analyze has a name, and (optionally) a list of
% parametric modulators.  E.g., for 2 conditions, where the second has
% 2 parametric modulators:
%
%  jp_spm8_specify1stlevel.conditions(1).name = 'noise';
%  jp_spm8_specify1stlevel.conditions(2).name = 'speech';
%  jp_spm8_specify1stlevel.conditions(2).p(1).name = 'modulator1';
%  jp_spm8_specify1stlevel.conditions(2).p(2).name = 'modulator2';
%
% The order of the parametric modulator can also be set (if not set, assumed 1):
%
%  jp_spm8_specify1stlevel.conditions(2).p(2).order = 2;
%
% See JP_DEFAULTS_SPMFMRI for a full list of defaults.
%
% Each subject needs an ev ("explanatory variable") file for each
% condition specified in info.conditions. These can be a single
% column, in which case it is assumed that the numbers refer to event
% onsets in event_units (scans/seconds). Alternatively, the ev file
% can be in a 3 column format, in which case the first column is the
% onset time (s), second column is event duration (s), and the third
% column is the weighting of the event.  This corresponds with the
% FSL custom file format. The EV files are in a subdirectory of the
% each subject's directory called 'ev_files' and named:
%
% SUBJECT.ev.CONDITION.SESSION
%
% 
% Parametric modulators are appended to the end of that name:
%
% SUBJECT.ev.CONDITION.SESSION-MODULATORNAME
%
%
% Sometimes you might want to analyze your sessions separately, for
% example, if they have different scanning parameters, etc. In this case
% set the separatesessions option to 1.  The TR for each session will be
% picked up appropriately from the info* files you created to set up the
% analysis (see JP_SPM_SETUP).
%
% Remember that the first scan in any session is scan 0, as well
% as time = 0 seconds.
%
% You should make sure to review your design at some point to make sure it
% looks reasonable.
%
% See SPM_FMRI_DESIGN and SPM_SPM for the structure of the SPM
% struct.

% Jonathan Peelle
% University of Pennsylvania

subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);


% log files
[alllog, errorlog, modellog] = jp_createlogs(subname, S.subjdir, mfilename);


% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);

if isempty(cfg.statsdir)
  jp_log(modellog, 'Must specify stats directory!', 2);
end


% Error checking
% options T and T0 can be set differently for each session; if just
% specified once, copy that for all sessions

if length(cfg.T)==1
  cfg.T = ones(1,length(S.subjects(subnum).sessions)) * cfg.T;
end

if length(cfg.T0)==1
  cfg.T0 = ones(1,length(S.subjects(subnum).sessions)) * cfg.T0;
end

if isempty(cfg.conditions) || length(cfg.conditions)==0
  jp_log(modellog, 'WARNING: No conditions specified.\n');
  pause(2);
end

% Make sure explicit masks exist (if specified)
if ~isempty(cfg.xM.VM)
  if ischar(cfg.xM.VM)
    cfg.xM.VM = cellstr(cfg.xM.VM);
  end
  VM = cfg.xM.VM;
  for v=1:length(VM)
    if ~exist(VM{v})
      error('Mask %s not found.', VM{v});
    end
  end
end

% put info back in S
S.cfg.(mfilename) = cfg;


% Keep track of original working directory so we can get back here.
originalDir = pwd;


jp_log(modellog, 'Running JP_SPM8_MODEL...\n');


% Make sure stats directory exists.
if ~exist(cfg.statsdir)
  mkdir(cfg.statsdir);
end

% Run the model for all sessions (normal) or for one session at a
% time (rare)
if cfg.separatesessions==0
  runmodel(S, subnum, 1:length(S.subjects(subnum).sessions));  
else
  for s=1:length(S.subjects(subnum).sessions)
    runmodel(S, subnum, s);
  end  
end % separatesession check


% Go back to wherever we were
cd(originalDir);

fprintf('** Make sure you review your model at some point! **\n');

end % main function



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function runmodel(S, subnum, sessionnum)


SPM = struct();

% log files
[alllog, errorlog, modellog] = jp_createlogs(S.subjects(subnum).name, S.subjdir, mfilename);


cfg = S.cfg.jp_spm8_specify1stlevel;

subjdir = S.subjdir;
thissub = S.subjects(subnum).name;


savepath = fullfile(cfg.statsdir, thissub);
if cfg.separatesessions > 0
  savepath = [savepath '_' S.subjects(subnum).sessions(sessionnum).name];
end
  
if ~isdir(savepath)
  mkdir(savepath);
end
cd(savepath);

SPM.swdir = savepath;

% Things that aren't session specific
SPM.xBF.name = cfg.bf_name;
SPM.xBF.length = cfg.bf_length;
SPM.xBF.order = cfg.bf_order;
SPM.xBF.UNITS = cfg.event_units;
SPM.xBF.Volterra = cfg.volterra;
SPM.xX.K(1).HParam = cfg.highpass_cutoff; 



% Make sure these values make sense
    
if ~ismember(SPM.xBF.name, {'hrf', 'hrf (with time derivative)',...
                      'hrf (with time and dispersion derivatives)',...
                      'Fourier set', ...
                      'Fourier set (Hanning)', ...
                      'Gamma functions', ...
                      'Finite Impulse Response'})
  error('Basis function not recognized.');
end
    
    
if ~ismember(SPM.xBF.UNITS, {'secs', 'scans'})
  error('event_units must be ''scans'' or ''seconds''.');
end
    
% Autocorrelations
SPM.xVi.form = cfg.autocorrelations;

% Global normalization
SPM.xGX.iGXcalc = cfg.global_normalization;


SPM.nscan = [];
SPM.xY.P = [];
P = [];

imgfilter = sprintf('^%s%s.*\\.%s$', cfg.prefix, S.subjects(subnum).funprefix, S.cfg.options.mriext);

for s=1:length(sessionnum)
  ss = sessionnum(s);
  
  thissession = S.subjects(subnum).sessions(ss).name;
  
  % this can all be session specific
  SPM.xY.RT = S.subjects(subnum).sessions(ss).tr; 
  SPM.xBF.T = cfg.T(ss);
  SPM.xBF.T0 = cfg.T0(ss); 
  SPM.xBF.dt = S.subjects(subnum).sessions(ss).tr/SPM.xBF.T;
  
  SPM.xBF = spm_get_bf(SPM.xBF);
  
  evpath = fullfile(subjdir, thissub, cfg.evdir);
  
  
  tmp_dir = fullfile(subjdir, thissub, S.subjects(subnum).sessions(ss).name);

  jp_log(modellog, sprintf('Getting files from %s...\n', tmp_dir));

  tmpFiles = spm_select('fplist',tmp_dir, imgfilter);    
  
  SPM.nscan(s) = size(tmpFiles,1);
  
  jp_log(modellog, sprintf('\tFound %i files.\n', size(tmpFiles,1)));
  
  P = strvcat(P,tmpFiles);


  % Get the condition onsets.  If a subject doesn't have a condition,
  % optionally add an onset corresponding to the last scan of that
  % session; this keeps the number of columns the same but shouldn't
  % appreciably effect the model.
  
  % sc = subject conditions, those actually used
  sc = 1;
  sub_conditions = {};  % the ones we actually use
   
  
  for c=1:length(cfg.conditions)
    
    thiscond = cfg.conditions(c).name;
    
    evfile = fullfile(evpath, sprintf('%s.ev.%s.%s', thissub, thiscond, thissession));

    if exist(evfile) || cfg.fixemptyconditions==1
      if exist(evfile)
        [onsets, durations] = jp_spm_getev(evfile);
      else
        jp_log(modellog, sprintf('EV file %s not found; adding dummy scan to ensure even number of columns.\n', evfile));
        onsets = SPM.nscan(ss) - 1;
        durations = 0;
        
        % make in seconds if appropriate
        if strcmp(cfg.event_units,'secs')
          onsets = onsets * S.subjects(subnum).sessions(ss).tr;
        end
      end

      SPM.Sess(s).U(sc).dt = SPM.xBF.dt;
      SPM.Sess(s).U(sc).name = cellstr(cfg.conditions(c).name);
      SPM.Sess(s).U(sc).ons = onsets;
      SPM.Sess(s).U(sc).dur = durations;
      SPM.Sess(s).C.C = [];
      SPM.Sess(s).C.name = {};
      
      % parametric modulators?
      if ~isfield(cfg.conditions, 'p') || isempty(cfg.conditions(1).p)      
        SPM.Sess(s).U(sc).P(1).name = 'none';
      else
        for p=1:length(cfg.conditions(c).p)
          pname = cfg.conditions(c).p(p).name;
          pfile = [evfile '-' pname];
          
          if exist(pfile)
            jp_log(modellog, sprintf('Adding %s...', pfile));
            pval = dlmread(pfile);
          else
            jp_log(errorlog, sprintf('Parametric modulator specified but %s not found.\n'));
          end
          
          SPM.Sess(s).U(sc).P(p).name = cfg.conditions(c).p(p).name;
          SPM.Sess(s).U(sc).P(p).P = pval;
          
          if ~isfield(cfg.conditions(c).p(p), 'order')
            SPM.Sess(s).U(sc).P(p).h = 1;
          else
            SPM.Sess(s).U(sc).P(p).h = cfg.conditions(c).p(p).order;
          end
          
          jp_log(modellog, 'done.\n');
        end % going through modulators
      end % checking for parametric modulators
      
      sub_conditions{sc} = thiscond;
      
      sc = sc + 1; % increment the counter for conditions we are using
    else
      jp_log(modellog, sprintf('EV file %s not found; skipping.\n', evfile));
    end
    
  end % going through conditions
  
  % If no conditons, make sure these fields are added
  if ~isfield(SPM, 'Sess')
    SPM.Sess = struct();
  end
  
  if ~isfield(SPM.Sess, 'C')
    SPM.Sess(s).C = struct();
    SPM.Sess(s).C.C = [];
    SPM.Sess(s).C.name = {''};
  end
  
  % Keep track of which conditions we actually used
  S.subjects(subnum).sub_conditions = sub_conditions;
    
  % Optionally, automatically get rp_* files for movement parameters
  if cfg.include_movement > 0
    jp_log(modellog, 'Adding movement parameters...');
    
    rpfile = spm_select('fplist', fullfile(subjdir, thissub, thissession),'^rp_');
      
    if size(rpfile,1) > 1
      jp_log(modellog, sprintf('More than one rp_ file exists for subject %s in %s. There needs to be just one.', thissub, thissession), 2);
    end
    
      [rp1 rp2 rp3 rp4 rp5 rp6] = textread(rpfile,'%f%f%f%f%f%f');
      
      SPM.Sess(s).C.C = [SPM.Sess(s).C.C rp1 rp2 rp3 rp4 rp5 rp6];
      SPM.Sess(s).C.name = cat(2,SPM.Sess(s).C.name,{'X','Y','Z','Roll','Pitch','Yaw'});

      jp_log(modellog, 'done.\n');
  end % end including movement for this session
  
  
  if cfg.include_badscans > 0
    jp_log(modellog, 'Adding columns for bad scans...');
    
    badscans = dlmread(fullfile(subjdir, thissub, thissession, cfg.badscansfilename));
    
    for bs=1:length(badscans)
      bsregress = zeros(SPM.nscan(s),1);
      bsregress(badscans(bs)) = 1;
      SPM.Sess(s).C.C = [SPM.Sess(s).C.C bsregress];
      SPM.Sess(s).C.name = cat(2,SPM.Sess(s).C.name, sprintf('badscan %i', bs));
    end    
    jp_log(modellog, 'done.\n');
  end
    
end % going through all sessions to be modeled right now


SPM.xY.P = P;

% make sure we actually found some images
if size(P,1)==1 && strcmp('/', P(1,:))
  jp_log(modellog, 'Did not find any images. Check to make sure your cfg.jp_spm8_specify1stlevel.prefix is correct.', 2);
else
  jp_log(modellog, sprintf('%i total files found across all sessions.\n', size(P,1)));
end

% Make sure we have some conditions
if length(sub_conditions)==0
  jp_log(modellog,sprintf('No valid conditions for subject %s, although some were specified.', thissub), 2);
end


% Configure design matrix
jp_log(modellog,'Configuring design matrix...\n');
SPM = spm_fmri_spm_ui(SPM);
jp_log(modellog,'Done configuring design matrix.\n');


% set any additional masking parameters
if ~isempty(cfg.xM.TH)
  SPM.xM.TH = ones(size(SPM.xM.TH)) .* cfg.xM.TH;
end

if ~isempty(cfg.xM.VM)
  
  if ischar(cfg.xM.VM)
    cfg.xM.VM = cellstr(cfg.xM.VM);
  end
  
  SPM.xM.VM = spm_vol(cfg.xM.VM{1});
  
  for v=2:length(cfg.xM.VM)
    SPM.xM.VM(v) = spm_vol(cfg.xM.VM{v});
  end
end

SPM.xM.I = cfg.xM.I;


save SPM SPM


% design reporting, saving?
if cfg.savedesignmatrix > 0
  fname = cat(1,{SPM.xY.VY.fname}');
  spm_DesRep('DesMtx', SPM.xX, fname, SPM.xsDes)

  % as a pdf
  basename = fullfile(savepath, 'design_matrix');
  job.fname = [basename '.pdf'];
  job.opts.opt = {'-dpdf'};
  spm_print(job);

  % as a png
  job.fname = [basename '.png'];
  job.opts.opt = {'-dpng', '-r200'};
  spm_print(job);
end

end % runmodel subfunction

    
