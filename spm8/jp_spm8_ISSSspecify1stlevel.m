function S = jp_spm8_ISSSspecify1stlevel(S, subnum)
%JP_SPM8_ISSSSPECIFY1STLEVEL Design first-level model with SPM8.
%
% S = JP_SPM8_ISSSSPECIFY1STLEVEL(S, SUBNUM) constructs a first level
% model on the specified subject number SUBNUM from an S structure
% (see JP_INIT).
%
% The analysis options are identical to JP_SPM8_SPECIFY1STLEVEL, with
% additional options intended for use with ISSS sequences:
%
%   pattern -      indicates the pattern of the ISSS sequence, 0 for
%                  dummy scans and 1 for real scans. Required.
%
%   fillwithmean - indicates whether to pad design matrix with mean
%                  images for dummy images (assuming that no .nii
%                  files exist for dummy images). Default 1.
%
%   meanname -     the prefix of the mean session images if fillwithmean is
%                  used. Must be specified if fillwithmean = 1.
%
%
% Remember, when setting the pattern, this should begin with the first scan
% that SPM knows about. It may be that this is different than you thought
% about programming the sequence.  For example, you may think about each
% pattern as starting with silence (for sound presentation) and ending with
% data collection, so dummry scans then real scans.  However, if the first
% scan that SPM knows about is the first real scan, then specify the
% pattern to start with real scans.
%
% You may want to use JP_SPM8_MEANFUNCTIONALPERSESSION to create
% the mean image used above.

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

if cfg.fillwithmean==1 && isempty(cfg.meanname)
  jp_log(modellog, 'Must specify meanname!', 2);
end

if isempty(cfg.pattern)
  jp_log(modellog, 'Must specify ISSS pattern!', 2);
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


cfg = S.cfg.(mfilename);

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
  
  
  % ----- this section edited to handle ISSS designs
  
  % get mean image
  thismean = spm_select('fplist', tmp_dir, sprintf('^%s', cfg.meanname));
  
  if size(thismean,1)~=1
    jp_log(modellog, sprintf('Mean session image not found in %s.\n', tmp_dir), 2);
  else
    jp_log(modellog, sprintf('Found mean image %s.\n', thismean(1,:)));
  end
  
  % see whether images already found make sense given the ISSS setup-
  % should have an equal number of patterns.
  
  nreal = sum(cfg.pattern); % sum all 1s, which are real scans
  modscans =  mod(size(tmpFiles,1), nreal);
  
  if modscans==0
    nrep = size(tmpFiles,1)/nreal;  % this should be the number of repetitions
    jp_log(modellog, sprintf('%i real scans per pattern = %i repetitions of pattern for this session.\n', nreal, nrep));
  else
    jp_log(modellog, 'Have an uneven number of scans for this session.', 2);
  end
    
  % Repeat the ISSS pattern the appropriate number of times. This should
  % indicate all of the rows in the model (i.e., continuous in time), and
  % for each scan, whether it is a real scan or a dummy scan. We can then
  % go through and construct a new list of files (tmp2) that will use
  % appropriate real and dummy scans.
  allpattern = repmat(cfg.pattern, 1, nrep);
  
  jp_log(modellog, sprintf('Constructing design matrix with %i total scans (real+dummy).\n', length(allpattern)));
  
  tmp2 = [];
  
  rcount = 1; % which real scan should be used?
  
  for q=1:length(allpattern)
    if allpattern(q)==1
      tmp2 = strvcat(tmp2, tmpFiles(rcount,:));
      rcount = rcount + 1; % (increment to next real)
    else
      tmp2 = strvcat(tmp2, thismean);
    end
  end
  
  
  % ----- end ISSS code for image selection (regressors added later!)
  
  
  
  SPM.nscan(s) = size(tmp2,1);
  
  jp_log(modellog, sprintf('\tFound %i files (real + dummy).\n', size(tmp2,1)));
  
  P = strvcat(P,tmp2);


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
      if ~isfield(cfg.conditions, 'p') || isempty(cfg.conditions(c).p)
        SPM.Sess(s).U(sc).P(1).name = 'none';
      else
        for p=1:length(cfg.conditions(c).p)
          if strcmp(lower(cfg.conditions(c).p(p).name), 'none')
            pname = 'none';
          else
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
        end
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
    SPM.Sess(s).C.name = {};
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
     
       
      % adjust for ISSS: mean-center and deal with dummy scans      
      rp1 = rp1 - mean(rp1);
      rp2 = rp2 - mean(rp2);
      rp3 = rp3 - mean(rp3);
      rp4 = rp4 - mean(rp4);
      rp5 = rp5 - mean(rp5);
      rp6 = rp6 - mean(rp6);
      
      rpall = zeros(SPM.nscan(s),6);
      rpall(find(allpattern),:) = [rp1 rp2 rp3 rp4 rp5 rp6];            
  
      
      SPM.Sess(s).C.C = [SPM.Sess(s).C.C rpall];
      SPM.Sess(s).C.name = cat(2,SPM.Sess(s).C.name,{'X','Y','Z','Roll','Pitch','Yaw'});

      jp_log(modellog, 'done.\n');
  end % end including movement for this session
  
  
  if cfg.include_badscans > 0
    jp_log(modellog, 'Adding columns for bad scans...');
    
    badscans = dlmread(fullfile(subjdir, thissub, thissession, cfg.badscansfilename));
    
    
    for bs=1:length(badscans)
      bsregress = zeros(SPM.nscan(s),1);      
      realscans = find(allpattern==1);  % to deal with ISSS    
      bsregress(badscans(realscans(bs))) = 1;
      SPM.Sess(s).C.C = [SPM.Sess(s).C.C bsregress];
      SPM.Sess(s).C.name = cat(2,SPM.Sess(s).C.name, sprintf('badscan %i', bs));
    end    
    jp_log(modellog, 'done.\n');
  end
  
  
  % Add regressors for ISSS: 1 for all dummy scans
  if ~isfield(SPM.Sess, 'C')
    SPM.Sess(s).C = struct();
    SPM.Sess(s).C.C = [];
  end
  SPM.Sess(s).C.name = cat(2, SPM.Sess(s).C.name, [thissession ' dummies']);
  
  SPM.Sess(s).C.C = [SPM.Sess(s).C.C (allpattern==0)'];
  
  
end % going through all sessions to be modeled right now


SPM.xY.P = P;

% make sure we actually found some images
if size(P,1)==1 && strcmp('/', P(1,:))
  jp_log(modellog, 'Did not find any images. Check to make sure your cfg.jp_spm8_modeldesign.prefix is correct.', 2);
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
  job = [];
  fig = spm_figure('FindWin', 'Graphics');
  if fig==0
    fig = spm_figure('Create', 'Graphics', 'Graphics');
  end
  job.fig.figname = 'Graphics';
  fname = cat(1,{SPM.xY.VY.fname}');
  spm_DesRep('DesMtx', SPM.xX, fname, SPM.xsDes)

  % as a pdf
  basename = fullfile(savepath, 'design_matrix');
  job.fname = [basename '.pdf'];
  job.opts.append = 1;
  job.opts.opt = {'-dpdf'};
  spm_print(job);

  % as a png
  job.fname = [basename '.png'];
  job.opts.opt = {'-dpng', '-r200'};
  spm_print(job);
end

end % runmodel subfunction

    
