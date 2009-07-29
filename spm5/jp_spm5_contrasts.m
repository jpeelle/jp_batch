function S = jp_spm5_contrasts(S, subnum)
%JP_SPM5_CONTRASTS runs contrasts for list of subjects with SPM5.
%
% S = JP_SPM5_CONTRASTS(S, subnum) uses the .m
% file contrasts.m residing in the stats dir to define and run
% contrasts. Contrasts.m should be a function set up like so:
%
%   function c = contrasts()
%
%   c(1).name = 'CN: First presentation';
%   c(1).con = [1 0 0 -1];
%   c(1).STAT = 'T';
%
%   etc.
%
% If STAT is not specified, it is assumed to be 'T'.
%
% Contrasts will be added to SPM.mat in the order that they are
% entered, i.e., SPM.xCon(1) has the information from c{1}.
%
% ANY EXISTING CONTRASTS (i.e., defaults, or other ones you have
% done) in SPM.xCon will WIPED OUT!  CAREFUL!  Basically if you
% just add new contrasts to the end of contrasts.m, re-running
% should never give you problems, but if you change the earlier
% ones, it's probably best to just delete your old contrasts and start
% again.
%
% Softlinks to the resulting con* files are stored in the @con_files folder
% (within the STATSDIR) for easy second level testing.  Likewise spmT*
% and spmF* files are stored in the @tandf_files directory.If you
% re-run any contrasts make sure these are updated.  THESE
% OVERWRITE existing con* and spmT* files.
%
% Options in S.cfg.jp_spm5_contrasts include:
%   which_contrasts     which contrasts to estimate (useful if you add more)
%   separatesessions    to run on separate session analysses (rare)   
%
%
% The which_contrasts field will start estimate the
% contrasts in the vector specified. (This is passed to
% spm_contrasts as the Ic parameter.)  If you run
% JP_SPM5_CONTRASTS once with 10 contrasts, then add 2 more to
% your contrasts.m file and re-run it starting with
% which_contrasts = [11 12], you're fine.  But
% note that the first 10 contrasts will be re-defined in your
% SPM.mat file, just not re-estimated, which is OK, since they
% haven't changed.  The problem is if you add 2 contrasts and also
% change contrast 3, you would then want WHICHCONTRASTS = [3 11
% 12], and you will probably have to manually click through
% confirmation dialogs since you are overwriting previous files.
% Just be careful.
%
%  See also JP_BATCH and JP_SPM5_MODEL.

subname = S.subjects(subnum).name;
statsdir = S.cfg.jp_spm5_contrasts.statsdir;

% log files
[alllog, errorlog, contrastslog] = jp_createlogs(subname, S.subjdir, mfilename);


% make sure statsdir is specified
if isempty(statsdir)
  jp_log(contrastslog, 'S.cfg.jp_spm5_contrasts.statsdir must be specified.', 2);
elseif ~isdir(statsdir)
  jp_log(contrastslog, sprintf('Statsdir %s not found.', statsdir), 2);
end

  



% Keep track of original working directory so we can get back here.
originalDir = pwd;


S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);



% Make sure the required contrasts.m file exists
confile = fullfile(statsdir,'contrasts.m');
if ~exist(confile, 'file')
  error('Required file %s is missing.  Type HELP JP_SPM5_CONTRASTS for more.', confile);
end


% Go to the stats dir
cd(statsdir);


% Load contrasts
jp_log(contrastslog, 'Loading contrasts...');
c = contrasts;  % the contrasts function
jp_log(contrastslog, sprintf('done. %i contrasts specified.\n', length(c)));


which_contrasts = cfg.which_contrasts;

% If not specified, run all contrasts
if isempty(which_contrasts)
  which_contrasts = 1:length(c);
end



% Error checking: make sure all of the contrast fields make sense
jp_log(contrastslog, 'Making sure contrasts make sense...\n');

for w = 1:length(which_contrasts)
    
  this_c = which_contrasts(w);
  
  jp_log(contrastslog, sprintf('Contrast %i...',which_contrasts(w)));
  
  
  % If not specified, assume a T test.
  if ~isfield(c, 'STAT') || isempty(c(this_c).STAT)
    c(this_c).STAT = 'T';
  end
  

  if isempty(c(this_c).name)
    error('The name for contrast %i is empty.',this_c);
  elseif ~ischar(c(this_c).name)
    error('The name for contrast %i is not a string.',this_c);
  elseif isempty(c(this_c).con)
    error('The .con for contrast %i is empty.',this_c);
  elseif ischar(c(this_c).con)
    error('The .con for contrast %i is not a matrix.',this_c);        
  elseif ~strcmp(c(this_c).STAT,'T') && ~strcmp(c(this_c).STAT,'F')
    error('The type of contrast %i is not T or F.',this_c);
  else
    jp_log(contrastslog, 'done.\n');
  end
  
end

jp_log(contrastslog, 'Done checking contrasts to see if they make sense.\n');



% Do contrasts

% If the contrasts directory doesn't exist, create it.
if ~isdir(fullfile(statsdir,cfg.confiledirname))
  jp_log(contrastslog, 'Creating con_files directory...');
  mkdir(fullfile(statsdir,cfg.confiledirname))
  jp_log(contrastslog, 'done.\n');
end

if ~isdir(fullfile(statsdir,cfg.tandffiledirname))
  jp_log(contrastslog, 'Creating tandf_files directory...');
  mkdir(fullfile(statsdir,cfg.tandffiledirname))
  jp_log(contrastslog, 'done.\n');
end



% Run the model for all sessions (normal) or for one session at a
% time (rare)
if S.cfg.jp_spm5_contrasts.separatesessions==0
  runcontrasts(S, fullfile(statsdir,subname), c, which_contrasts);
else
  for s=1:length(S.subjects(subnum).sessions)
    runcontrasts(S, fullfile(statsdir, [subname '_' S.subjects(subnum).sessions(s).name]), c, which_contrasts);
  end  
end % separatesession check


% Back to wherever we started.
cd(originalDir)


end %main function





function runcontrasts(S, condir, c, which_contrasts)
% Go to this subject's stats dir and load their SPM.mat.
% (c = contrasts)


statsdir = S.cfg.jp_spm5_contrasts.statsdir;


cd(condir);
fprintf('Loading SPM.mat...');
load SPM
fprintf('done.\n');



% Fill in SPM.xCon


for i = 1:length(which_contrasts)
  this_c = which_contrasts(i);
  fprintf('\tContrast %i: %s (%s contrast)...', this_c, c(this_c).name, c(this_c).STAT);
  
  if ~isfield(SPM,'xCon') || isempty(SPM.xCon)
    SPM.xCon = struct();
    SPM.xCon = spm_FcUtil('Set',c(this_c).name, c(this_c).STAT,'c', c(this_c).con', SPM.xX.xKXs);
  else
    SPM.xCon(this_c) = spm_FcUtil('Set',c(this_c).name, c(this_c).STAT,'c', c(this_c).con', SPM.xX.xKXs);
  end
  fprintf('done.\n');
end


fprintf('done.\n');



% Run the contrasts.
fprintf('Running contrasts...\n');

spm_contrasts(SPM, which_contrasts);  % also saves SPM.mat


% Copy the contrasts to the directory in statsdir/contrasts
fprintf('Making softlinks to contrast images...\n');

try
    
  for w = 1:length(which_contrasts)
    
    this_c = which_contrasts(w);      
    cdir = fullfile(statsdir,fix_string(S.cfg.jp_spm5_contrasts.confiledirname),fix_string(c(this_c).name));
    
    
    % fix_string makes string suitable for passing to system because it
    % preprents a \ to each > sign, for example.  But this isn't good for
    % Matlab functions like isdir and mkdir.  The goodfordir function
    % removes backslashes from the string. 
    
    if ~exist(goodfordir(cdir)); mkdir(goodfordir(cdir)); end
    
    % Change what we copy depending on whether it's a T or F test
    
    [pth, condir_local] = fileparts(condir);
    
    if strcmp(c(this_c).STAT,'T')
      system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('con_%04i.img',this_c)), fullfile(cdir,sprintf('%s_con_%04i.img',condir_local,this_c))));
      system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('con_%04i.hdr',this_c)), fullfile(cdir,sprintf('%s_con_%04i.hdr',condir_local,this_c))));
    else
      system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('ess_%04i.img',this_c)), fullfile(cdir,sprintf('%s_ess_%04i.img',condir_local,this_c))));
      system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('ess_%04i.hdr',this_c)), fullfile(cdir,sprintf('%s_ess_%04i.hdr',condir_local,this_c))));
    end
  end
  fprintf('done.\n');
catch
  fprintf('ERROR: There was an error making the softlinks to the con* files.\n');
end


% Copy the spmT and spmF files to the directory in statsdir/contrasts
fprintf('Making softlinks to spmT and spmF images...\n');
try
  for w = 1:length(which_contrasts)
    
    this_c = which_contrasts(w);
    tdir = fullfile(statsdir,fix_string(S.cfg.jp_spm5_contrasts.tandffiledirname),fix_string(c(this_c).name));
    
    if ~isdir(goodfordir(tdir)); mkdir(goodfordir(tdir)); end
    
    % Change what we copy depending on whether it's a T or F test
    if strcmp(c(this_c).STAT,'T')
      system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('spmT_%04i.img',this_c)),fullfile(tdir,sprintf('%s_spmT_%04i.img',condir_local,this_c))));
      system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('spmT_%04i.hdr',this_c)),fullfile(tdir,sprintf('%s_spmT_%04i.hdr',condir_local,this_c))));
    else
      system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('spmF_%04i.img',this_c)),fullfile(tdir,sprintf('%s_spmF_%04i.img',condir_local,this_c))));
      system(sprintf('ln -sf %s %s', fullfile(condir,sprintf('spmF_%04i.hdr',this_c)),fullfile(tdir,sprintf('%s_spmF_%04i.hdr',condir_local,this_c))));
    end
  end
  fprintf('done.\n');
catch
  fprintf('ERROR: There was an error making the softlinks to the spmT* files.\n');
end

end % runcontrasts


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


