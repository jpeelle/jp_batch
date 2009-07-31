function jp_spm_setup()
%JP_SPM_SETUP Set up the info files needed by JP_BATCH SPM scripts.
%
%  JP_SPM_SETUP saves info files needed by scripts for
%  preprocessing or statistics.

clc

fprintf('This script will save info files in your base directory.\n')
fprintf('If you don''t want a file saved, just press enter.\n');
fprintf('Any exisiting files info files will be overwritten.\n\n');


analysis_type = input('Directory type? (1 = subjects, 2 = stats): ');


if ~(analysis_type==1 || analysis_type==2)
  error('Must enter 1 or 2.');
end


[base_dir, sts] = spm_select(1, 'dir', 'Select the directory in which to save files.');
if ~isdir(base_dir) || sts==0
  error('Problem selecting original directory.')
end


if analysis_type==1
  setup_subj(base_dir);
else
  setup_stats(base_dir);
end



% All done
fprintf('\n------------------------------------------------------\n');
fprintf('\nDone setting up files in %s.\n', base_dir)
fprintf('If you want to check these files (a good idea!), you can type\n''less [file]'' from a terminal.\n');
fprintf('To edit, you can use vi or emacs.\n');

if analysis_type==1
  fprintf('\nRemember, these are used as defaults for all subjects. If you\n')
  fprintf('want to override one of these values, save another file in that\n')
  fprintf('subject''s directory. For example, if most subjects have two\n')
  fprintf('functional directories, the info.fundirs file might influde two\n')
  fprintf('lines: functional01 and functional01. However, if subject JR1234\n')
  fprintf('only has one functional directory, you would create JR1234.info.fundirs\n')
  fprintf('in that subject''s folder. This file would only contain a single\n')
  fprintf('line: functional01.\n');
end

end %main function




function setup_subj(base_dir)


% Structural directories
struct_dirs = {};
this_struct = input('\nEnter the first directory that contains structural images: ', 's');

while ~isempty(this_struct)
  struct_dirs = {struct_dirs{:} this_struct};  
  this_struct = input('Enter the name of another structural directory, or just enter if done: ', 's');
end


if ~isempty(struct_dirs)
  fid = fopen(fullfile(base_dir, 'info.structdirs'), 'w');
  for i=1:length(struct_dirs)
    fprintf(fid, '%s\n', struct_dirs{i});
  end
end


% Functional directories
fun_dirs = {};
this_fun = input('\nEnter the first directory that contains functional images: ', 's');

while ~isempty(this_fun)
  fun_dirs = {fun_dirs{:} this_fun};  
  this_fun = input('Enter the name of another functional directory, or just enter if done: ', 's');
end

if ~isempty(fun_dirs)
  fid = fopen(fullfile(base_dir, 'info.fundirs'), 'w');
  for i=1:length(fun_dirs)
    fprintf(fid, '%s\n', fun_dirs{i});
  end
end



% Struct prefix
fprintf('\nThe structural prefix refers to the letter(s) that start\nstructural filenames (often ''s'').\n');
structprefix = input('Enter your structural prefix: ', 's');
writestr(fullfile(base_dir, 'info.structprefix'), structprefix);


% Functional prefix
fprintf('\nThe functional prefix refers to the letter(s) that start\nfunctional filenames (often ''f'').\n');
funprefix = input('Enter your functional prefix: ', 's');
writestr(fullfile(base_dir, 'info.funprefix'), funprefix);


% TA
fprintf('\nYour TA is how long it actually took to acquire a full volume.\n');
ta = input('Enter your TA (seconds): ');
if ~isempty(ta)
  dlmwrite(fullfile(base_dir, 'info.ta'), ta, 'delimiter', '\n');
end


% TR
fprintf('\nYour TR is the time between the beginning of one volume and the beginning of the next.\n');
fprintf('It is often the same as your TA, but not always.\n');
tr = input('Enter your TR (seconds): ');
if ~isempty(tr)
  dlmwrite(fullfile(base_dir, 'info.tr'), tr, 'delimiter', '\n');
end


% Sliceorder
fprintf('\nThe order in which slices are acquired is important for slicetiming correction.\n');
fprintf('This will interpret Matlab expressions, so if you collect in ascending order,\n');
fprintf('you could simply type 1:32.\n');
sliceorder = input('Enter your sliceorder: ', 's');


if ~isempty(sliceorder)
  sliceorder = eval(sliceorder);
  dlmwrite(fullfile(base_dir, 'info.sliceorder'), sliceorder, 'delimiter', '\n');
  suggested_ref = sliceorder(round(length(sliceorder)/2));
else
  suggested_ref = 1;
end



% Ref slice
fprintf('\nThe reference slice is used for slicetiming and is the slice you align your\n');
fprintf('data to. Often people choose the middle slice acquired in time.\n');
ref_slice = input(sprintf('Enter your reference slice (suggested %i): ', suggested_ref));
if ~isempty(ref_slice)
  dlmwrite(fullfile(base_dir, 'info.refslice'), ref_slice, 'delimiter', '\n');
end

end % setup_subj



function setup_stats(base_dir)


% Event units
fprintf('\nWhen you enter the times for your events, they can be in scans or seconds.\n');
event_units = input('Enter 1 to measure in scans, 2 to measure in seconds: ');

if event_units==1
  event_units = 'scans';
elseif event_units==2
  event_units = 'secs';
else
  event_units = [];
  fprintf('Did not recognize your response.  Skipping info.event_units.\n');
end
  
writestr(fullfile(base_dir, 'info.event_units'), event_units);
  
 

% HRF name
fprintf('\nSPM uses a set of one or more basis functions to estimate neural activity\n');
fprintf('based on the events you give it.  Three common sets of basis functions are listed\n');
fprintf('below (if you need another option, you will have to make the file manually):\n');
fprintf('\t1) hrf\n');
fprintf('\t2) hrf (with time derivative)\n');
fprintf('\t3) hrf (with time and dispersion derivatives)\n');
fprintf('\t4) other (you will create info.bf_name on your own later)\n\n');

bf_name = input('Please indicate which basis function to use: ');

if bf_name==1
  bf_name = 'hrf';
elseif bf_name==2
  bf_name = 'hrf (with time derivative)';
elseif bf_name==3
  bf_name = 'hrf (with time and dispersion derivatives)';
else
  bf_name = [];
end

writestr(fullfile(base_dir, 'info.bf_name'), bf_name);


% BF length
fprintf('\nSPM will model the basis set for a certain period of time. The default\n');
fprintf('is 32 seconds, which is probably fine if you''re not sure.\n');
bf_length = input('Enter the length to model the basis function for (in seconds): ');
if ~isempty(bf_length)
  dlmwrite(fullfile(base_dir, 'info.bf_length'), bf_length, 'delimiter', '\n');
end


% (HRF order - shouldn't need for these easy ones)
fprintf('\n(You don''t need info.bf_order for canonical HRFs, so it will automatically be set to 1.)\n');
dlmwrite(fullfile(base_dir, 'info.bf_order'), [1], 'delimiter', '\n');



% Conditions
fprintf('\n\nThe info.conditions file determines which conditions are included in your model.\n');
fprintf('Enter all the conditions you want included, one at a time. Capitalization matters.\n');
fprintf('Avoid spaces in your condition names.\n');


conditions = {};
this_condition = input('\nEnter the name of the first condition: ', 's');

while ~isempty(this_condition)
  conditions = {conditions{:} this_condition};  
  this_condition = input('Enter the name of another condition, or just enter if done: ', 's');
end

if ~isempty(conditions)
  fid = fopen(fullfile(base_dir, 'info.conditions'), 'w');
  for i=1:length(conditions)
    fprintf(fid, '%s\n', conditions{i});
  end
end



end % setup_stats



function writestr(f, string)
if ~isempty(string)
  fid = fopen(f, 'w');
  fprintf(fid, '%s\n', string);
  fclose(fid);
end
end



