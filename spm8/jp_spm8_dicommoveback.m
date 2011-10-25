function S = jp_spm8_dicommoveback(S, subnum)
%JP_SPM8_DICOMMOVEBACK Reset if you need to re-run JP_SPM8_DICOMCONVERT.


cfg = [];
cfg.gunzip = 1;

subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);
od = pwd; % get original directory; go back here at the end

% log files
[alllog, errorlog, convertlog] = jp_createlogs(subname, S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
%S.cfg = jp_setcfg(S.cfg, mfilename);
%cfg = S.cfg.(mfilename);

try
  sessions = jp_getsessions(S, subnum);
catch
  sessions = jp_getinfo('sessions', S.subjdir, subname);
end

try
  structdir = S.subjects(subnum).structdirs;
catch
  structdir = jp_getinfo('structdirs', S.subjdir, subname);
end

if ischar(structdir)
  structdir = cellstr(structdir);
end

% all the directories we're going to try to convert
dirs = {structdir{:} sessions{:}};


fprintf('Moving %s...', subname);
for i=1:length(dirs)
    fprintf('\tMoving %s...\n', dirs{i});
    thisdir = fullfile(S.subjdir, subname, dirs{i});
    dicomdir = fullfile(thisdir, 'DICOM');
   
    if cfg.gunzip > 0
        system(sprintf('gunzip %s/*.gz', dicomdir));
    end
    
    system(sprintf('mv %s/* %s/', dicomdir, thisdir));
    fprintf('done.\n');
end

fprintf('\n');


