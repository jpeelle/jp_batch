function S = jp_spm8_printresults(S, subnum)
%JP_SPM8_PRINTRESULTS Prints MIPs and tables for already-run contrasts.
%

% Jonathan Peelle


subname = S.subjects(subnum).name;
statsdir = S.cfg.jp_spm8_printresults.statsdir;

% log files
[alllog, errorlog, resultslog] = jp_createlogs(subname, S.subjdir, mfilename);


% make sure statsdir is specified
if isempty(statsdir)
  jp_log(resultslog, sprintf('S.%s.statsdir must be specified.', mfilename), 2);
elseif ~isdir(statsdir)
  jp_log(resultslog, sprintf('Statsdir %s not found.', statsdir), 2);
end


% get sessions
try
  sessions = jp_getsessions(S, subnum);
catch
  sessions = jp_getinfo('sessions', S.subjdir, subname);
end

% Keep track of original working directory so we can get back here.
originalDir = pwd;


S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);


% Run the model for all sessions (normal) or for one session at a
% time (rare)
if S.cfg.jp_spm8_contrasts.separatesessions==0
  runresults(S, subnum, fullfile(statsdir,subname));
else
  for s=1:length(S.subjects(subnum).sessions)
    runresults(S, subnum, fullfile(statsdir, [subname '_' S.subjects(subnum).sessions(s).name]));
  end  
end % separatesession check


% Back to wherever we started.
cd(originalDir)
close all
end % main function



function runresults(S, subnum, statsdir)
subname = S.subjects(subnum).name;

cfg = S.cfg.(mfilename);

swd = statsdir;
%cd(swd);
load(fullfile(swd, 'SPM.mat'));

pdfd = fullfile(statsdir, 'pdfs');
if ~isdir(pdfd)
  mkdir(pdfd);
end

if isempty(cfg.which_contrasts)
  which_contrasts = 1:length(SPM.xCon);
else
  which_contrasts = cfg.which_contrasts;
end

% for each contrast, loop through different significance levels and print

for c=1:length(which_contrasts)
  xs = struct();
  
  thisc = which_contrasts(c);
  xs.swd = swd;
  xs.Ic = thisc;
  title = SPM.xCon(thisc).name;
  pdffile = fullfile(pdfd, fix_string(title));
  
  for j=1:length(cfg.u)
    
    xs.k = cfg.k(j);
    xs.Im = cfg.Im{j};
    xs.u = cfg.u(j);
    xs.thresDesc = cfg.thresDesc{j};
    
    if strcmp(xs.thresDesc, 'none')
      desc = '(unc.)';
    else
      desc = xs.thresDesc;
    end
    
    xs.title = sprintf('%s %g %s', title, xs.u, desc);
    
    [hReg, xSPM] = spm_results_ui('setup', xs);
    spm_list('list', xSPM, hReg);
    
    % save to ps file
    job = struct();
    job.fname = pdffile;
    job.opts.append = 1;
    job.opts.opt = cfg.printopts; %{'-dpsc2'};
    job.opts.append = true;
    jobs.opts.ext = '.ps';
    if cfg.append > 0
      job.opts.opt = {job.opts.opt{:} '-append'};
    end
    spm_print(job);            
  end
  
  system(sprintf('ps2pdf %s.ps %s.pdf', job.fname, job.fname));
  system(sprintf('rm %s.ps', job.fname));
end % going through contrasts



% after all contrasts, run ps2pdf on the files and remove .ps files

end % runresults


function new_string = fix_string(s)
new_string = strrep(s,' ','_');
new_string = strrep(new_string,'>','\>');
new_string = strrep(new_string,'<','\<');
new_string = strrep(new_string,'(','_');
new_string = strrep(new_string,')','_');
new_string = strrep(new_string, '@', '\@');
end % fix_string

