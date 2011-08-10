function S = jp_spm8_dicomconvert(S, subnum)
%JP_SPM8_DICOMCONVERT Convert DICOM files to Nifti using SPM.
%
% JP_SPM8_DICOMCONVERT(S, SUBNUM) converts DICOM files to Nifti images.
%
% The assumption is that each subject's DICOM files are already sorted into
% structural and/or functional directories that correspond to those listed
% in info.sessions and info.structdir.  For each of these directories, the
% output (Nifti) files are saved in the file where the DICOM images are
% found.
%
% Options include:
%
%    filter = '^[0-9]{4}_[0-9]{8}_[0-9]{6}\.[0-9]{6}$'; 
%    opts = 'all';
%    root_dir = 'flat';
%    format = cfg.options.mriext; % img | nii 
%    after = 'gzip'; % preserve | gzip | delete | gzipmove
%
% The 'filter' option is a regular expression passed to spm_select for
% selecting DICOM files (in case there are other files in the directory);
% set to '.*' to select all files.  The 'after' option determines what is
% done with the DICOM files after conversion: either leaving them alone,
% gzipping them, deleting them, or gzipping and moving to a 'DICOM'
% subfolder (the default).

% Jonathan Peelle
% University of Pennsylvania

subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);
od = pwd; % get original directory; go back here at the end

% log files
[alllog, errorlog, convertlog] = jp_createlogs(subname, S.subjdir, mfilename);

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);

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


for i=1:length(dirs)
    thisdir = fullfile(S.subjdir, subname, dirs{i});
    jp_log(convertlog, sprintf('Searching for DICOM images in %s...\n', thisdir));
    
    % try to find some DICOM images
    cd(thisdir)
    P = spm_select('fplist', thisdir, cfg.filter);
    jp_log(convertlog, sprintf('\tFound %i DICOM images.\n', size(P,1)));
    
    if size(P,1) <= 1
        warning('No DICOM files selected for %s. Check your DICOM filter?', thisdir);
    else
        jp_log(convertlog, '\tConverting DICOM to Nifti...');
        hdr = spm_dicom_headers(strvcat(P), true);
        out = spm_dicom_convert(hdr, cfg.opts, cfg.root_dir, cfg.format);
        jp_log(convertlog, 'done.\n');
        jp_log(convertlog, sprintf('\t%i Nifti files created.\n', length(out.files)));
        
        if strcmp(lower(cfg.after), 'preserve')
            jp_log(convertlog, '\tLeaving DICOM files alone.\n');
        elseif strcmp(lower(cfg.after), 'gzip')
            jp_log(convertlog, '\tGzipping DICOM files...');
            for j=1:size(P,1)
                system(sprintf('gzip %s', deblank(P(j,:))));
            end
            jp_log(convertlog, 'done.\n');
        elseif strcmp(lower(cfg.after), 'delete')
            jp_log(convertlog, '\tDeleting DICOM Files...');
            for j=1:size(P,1)
                system(sprintf('rm %s', deblank(P(j,:))));
            end
            jp_log(convertlog, 'done.\n');
        elseif strcmp(lower(cfg.after), 'gzipmove')
            jp_log(convertlog, '\tGzipping DICOM files and moving to DICOM subdirectory...');
            dicomdir = fullfile(thisdir, 'DICOM');
            if ~isdir(dicomdir); mkdir(dicomdir); end
            
            for j=1:size(P,1)
                 system(sprintf('gzip %s', deblank(P(j,:))));
                 system(sprintf('mv %s.gz %s/', deblank(P(j,:)), dicomdir)); 
            end
            jp_log(convertlog, 'done.\n');
        else
            jp_log(convertlog, 'UNKNOWN option for what to do after DICOM conversion (cfg.after).')
        end
    end
    
end % going through dirs

% go back to original directory
cd(od);


