function S = jp_ft_getdata(S, subnum, blocknum)
%JP_FT_GETDATA Uses FieldTrip to read in a raw data file.
%
% Blocknames are taken from the SUBJ.blocknames text file in each
% subject's directory.
%
% BLOCKNAME is the name of the block to be read in.
%
% After succssfully reading in the data, the location of this data
% file is saved to
%
%    D.data.BLOCKNAME
%
% For each block, data are read from:
%
%  foo/subj/SUBJ/BLOCK/PREFIXBLOCK.fif
%
%
% The input S structure must include the following fields:
%
%    subjdir     main dir with subjects
%    subjname    this subject
%    fs          sampling rate (Hz)
%
% And options must include:
%    conditions  condition names
%
% If options.trialfile is specified as 1, a text file as assumed to
% be in blockname/subname_blockname_conditionname_trl.txt for each
% condition for each block.  If options.trialfile is 0, the following
% options are required and used to define trials in FieldTrip:
%
%    triggers    trigger for each condition
%    prestim     pre-trigger time kept
%    poststim    post-trigger time kept
%    analysisdir directory in which analysis is saved for each subject
%
%
% The length of conditions, triggers, prestim, and poststim should
%  be the same.
%
% And optionally
%
%    heog_label (default 'EEG061')
%    veog_label = (default 'EEG062')
%    ecg_label = (default 'EEG063')
%
%
% This will also try to find any EOG and ECG channels if present
% in the data based on channel labels containing the string
% 'HEOG', 'HVOG', or 'ECG'.  These are saved to B.data.block.HEOG
% etc. respectively.
%
%
% JP_EMEG_GETDATA can also make use of FieldTrip's
% artifact-rejection criteria; options in S.cfg.jp_emeg_getdata
% include:
%
%   veogreject        use EOG rejection (default 0)
%   veogreject_cfg    passed to fieldtrip (no defaults)
%   jumpreject        reject sensor jumps (default 0)
%   jumpreject_cfg    passed to fieldtrip (no defaults)
%
%
%
% CFG is passed to FieldTrip's PREPROCESSING function with the
% following defaults:
%
%    bpfilter = 'yes'
%    bpfreq = [0.1 30]
%    lpfilter = 'no'
%    hpfilter = 'no'
%    checkboundary = 0
%    continuous = 'yes'
%    channel = {'MEG'}
%    blc = 'yes'
%
%  
% But any other field accepted by PREPROCESSIONG should work as well.
%
% This blindly reads in the three specified channels, making no
% allowance for if they were not recorded.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



if nargin < 3
    error('There are required options.')
end

if ~isfield(options, 'fs') || isempty(options.fs)
  error('options.fs required.')
end

if ~isfield(options, 'conditions') || isempty(options.conditions)
  error('Must specifiy options.conditions.')
end

if ~isfield(options, 'triggers')
    options.triggers = [];
end

if ~isfield(options, 'prefix') || isempty(options.prefix)
    options.prefix = 'td4s'; % prefix to the fif file being read in
end

if ~isfield(options, 'outputfilename') || isempty(options.outputfilename)
    options.outputfilename = 'blockdata';
end

if ~isfield(options, 'analysisdir')
    error('options.analysisdir required')
end

% must have prestim and poststim

if ~isfield(options, 'trialfile')
    options.trialfile = 0;
end

if options.trialfile==0
  if ~isfield(options, 'prestim') || isempty(options.prestim)
    error('options.prestim is required if not specifying options.trialfile.')
  end
  
  if ~isfield(options, 'poststim') || isempty(options.poststim)
    error('options.poststim is required if not specifying options.trialfile.')
  end  
end


if ~isfield(options, 'cfg') || isempty(options.cfg)
  options.cfg = struct();
end

cfg = options.cfg;

if ~isfield(cfg, 'bpfilter') || isempty(cfg.bpfilter)
  cfg.bpfilter = 'yes';
end

if ~isfield(cfg, 'bpfreq') || isempty(cfg.bpfreq)
  cfg.bpfreq = [0.1 100];
end


if ~isfield(cfg, 'lpfilter') || isempty(cfg.lpfilter)
  cfg.lpfilter = 'no';
end

if ~isfield(cfg, 'hpfilter') || isempty(cfg.hpfilter)
  cfg.hpfilter = 'no';
end

if ~isfield(cfg, 'checkboundary') || isempty(cfg.checkboundary)
  cfg.checkboundary = 0;
end

if ~isfield(cfg, 'continuous') || isempty(cfg.continuous)
  cfg.continuous = 'yes';
end

if ~isfield(cfg, 'channel') || isempty(cfg.channel)
  cfg.channel = {'MEG'};
end

if ~isfield(cfg, 'blc') || isempty(cfg.blc)
  cfg.blc = 'yes';
end


if ~isfield(S, 'heog_label') || isempty(S.heog_label)
  S.heog_label = 'EEG061';
end

if ~isfield(S, 'veog_label') || isempty(S.veog_label)
  S.veog_label = 'EEG062';
end

if ~isfield(S, 'ecg_label') || isempty(S.ecg_label)
  S.ecg_label = 'EEG063';
end


if ~isfield(options, 'eogreject') || isempty(options.eogreject)
  options.eogreject = 0;
end

if ~isfield(options, 'jumpreject') || isempty(options.jumpreject)
  options.jumpreject = 0;
end

if options.eogreject==1 && ~isfield(options, 'eogreject_cfg')
  error('If eogreject==1, you must specify options.eogreject_cfg.')
end

if options.jumpreject==1 && ~isfield(options, 'jumpreject_cfg')
  error('If jumpreject==1, you must specify options.jumpreject_cfg.')
end



fprintf('Running JP_MEG_GETDATA...\n');

% check for required MNE files
if ~(exist('fiff_read_meas_info', 'file') && exist('fiff_setup_read_raw', 'file'));
    fprintf('MNE toolbox not found.  Will try adding /opt/mne/matlab/toolbox/, the CBU location, to matlab path.\n')
    addpath('/opt/mne/matlab/toolbox/')
end


% Keep track of original channels, since we overwrite cfg.channel to do EOG and
% ECG channels.
originalchannel = cfg.channel;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get some information from D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subjdir = S.subjdir;
subj = S.subjname;


triggers = options.triggers;
conditions = options.conditions;


S.analysisdir = options.analysisdir;
S.fs = options.fs;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the configuration and get the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Sfile = fullfile(S.subjdir, S.subjname, S.analysisdir, 'S.mat');


for b=1:length(blocknum)
  thisblock = S.blocknames{blocknum(b)};
  
  
  BD = struct();  % block data
  
  datafile = fullfile(subjdir, subj, thisblock, sprintf('%s%s.fif', options.prefix, thisblock));
  
  if ~exist(datafile)
    error('%s not found.', datafile)
  end
  
  fprintf('Found %s.\n', datafile);
  cfg.dataset = datafile;
  
  

  
  for j=1:length(conditions)
    
    cname = conditions{j};
    
    % set up the cfg for this condition        
    
    cfg.channel = originalchannel;
    
    if options.trialfile > 0
      tf = fullfile(subjdir, subj, thisblock, sprintf('%s_%s_%s_trl.txt', subj, thisblock, cname));
      if ~exist(tf)
        error('Trial file %s not found.', tf);
      end
      
      cfg.trl = dlmread(tf);
      
    else            
      cfg.trialdef.eventtype = 'STI101';
      cfg.trialdef.eventvalue = triggers(j);
      
      cfg.trialdef.prestim = options.prestim(j);
      cfg.trialdef.poststim = options.poststim(j);
    end

    
    % Optionally, reject artifacts
    if options.eogreject
      fprintf('Finding EOG artifacts...\n')
      cfg.artfctdef.eog = options.eogreject_cfg;
      cfg = artifact_eog(cfg);
    end % eogreject
    
    if options.jumpreject
      fprintf('Finding sensor jump artifacts...\n')
      cfg.artfctdef.jump = options.jumpreject_cfg;
      cfg = artifact_jump(cfg);
    end % jumpreject
    
    
    if options.eogreject || options.jumpreject
      fprintf('Getting rid of artifacts...');
      cfg.artfctdef.reject = 'complete';
      cfg = rejectartifact(cfg);
      fprintf('done.\n');
    end
  
    
    % save the cfg used for FieldTrip for this condition
    eval(sprintf('S.getdata.c%s.cfg = cfg;', cname));
    
    fprintf('Processing %s...\n', cname);
    

    % main data
    fprintf('Getting trial information...\n')
    
    
    if options.trialfile > 0
      ncfg = definetrial(cfg);
    else
      ncfg = cfg;
    end
    
    fprintf('Getting main data...\n')
    eval(sprintf('BD.c%s.data = preprocessing(ncfg);', cname));
    
    
    
    % EOG and ECG
    fprintf('\nGetting EOG and ECG...\n')
    ncfg.channel = S.heog_label;
    eval(sprintf('BD.c%s.heog = preprocessing(ncfg);', cname));
    
    ncfg.channel = S.veog_label;
    eval(sprintf('BD.c%s.veog = preprocessing(ncfg);', cname));
    
    ncfg.channel = S.ecg_label;
    eval(sprintf('BD.c%s.ecg = preprocessing(ncfg);', cname));
  end
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Save the output
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  savedir = fullfile(subjdir, subj, S.analysisdir, thisblock);
  if ~isdir(savedir)
    mkdir(savedir);
    end
    BDfile = fullfile(savedir, sprintf('%s.mat', options.outputfilename));
    save(BDfile, 'BD');
    
    clear data
    
    fprintf('Saved block %s data to %s.\n\n', thisblock, BDfile);
end % going through blocks


% update S, and save
S.blockdataname = options.outputfilename;
save(Sfile, 'S');


fprintf('Done with JP_MEG_GETDATA.\n');


