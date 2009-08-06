function jp_spm_viewmotion(baseDir,subjects, options)
%JP_SPM_VIEWMOTION view motion parameters from SPM realign.
%
%  JP_SPM_VIEWMOTION(BASEDIR,SUBJECTS) plots a figure for each of the
%  subjects specified functional directories (see JP_SPM_BATCH for how
%  these are specified).
%
%  JP_SPM_VIEWMOTION(BASEDIR, SUBJECTS, OPTIONS) lets you specify
%  the following options:
%
%  graph_each    whether to graph each subject (default 1)
%  graph_total   historgram of subject maximum values (default 0)
%
%  first         # scans included for average of first (default 50)
%  last          same for the average of last (default same as first)
%
%  save_vars  if set to 1 saves variables to viewmotion_vars.mat (defaults 0)
%
%  $Rev: 21 $
%  $LastChangedDate: 2008-08-29 15:06:08 +0100 (Fri, 29 Aug 2008) $

if ~isdir(baseDir)
    error('%s not found.',baseDir)
end


if nargin < 3 || isempty(options)
  options = struct();
end

if ~isfield(options,'graph_each') || isempty(options.graph_each)
  options.graph_each = 1;
end

if ~isfield(options, 'graph_total') || isempty(options.graph_total)
  options.graph_total = 0;
end

if ~isfield(options, 'first') || isempty(options.first)
  options.first = 50;
end

if ~isfield(options, 'last') || isempty(options.last)
  options.last = options.first;
end

if ~isfield(options, 'save_vars') || isempty(options.save_vars)
  options.save_vars = 0;
end

% make sure subjets are in the right format
if ischar(subjects) && size(subjects,1)==1
  subjects = {subjects};
end

fprintf('\n')

max_trans = zeros(length(subjects),1);
max_rot = zeros(length(subjects),1);

% These are the average across all scans for a subject, not just
% the max
avg_trans = zeros(length(subjects),1);
avg_rot = zeros(length(subjects),1);

% Averages for just the first and last bits
avg_trans_first = zeros(length(subjects),1);
avg_trans_last = zeros(length(subjects),1);
avg_rot_first = zeros(length(subjects),1);
avg_rot_last = zeros(length(subjects),1);

for s=1:length(subjects)
    

    thisSub = subjects{s};
    if ~isdir(fullfile(baseDir,thisSub))
        error('%s not found.',fullfile(baseDir,thisSub));
    end

    funDirs = jp_spm_getinfo('fundirs', baseDir,thisSub);

    rp = [];
    
    for d = 1:length(funDirs)
        
        thisDir = funDirs{d};
        
        % Get the rp_ file for this subject.
        w = dir(fullfile(baseDir,thisSub,thisDir,'rp_*.txt'));
    
        if size(w) ~= [1 1]
            fprintf('Warning: Problem retting rp_*.txt file for subject %s, directory %s.\n',thisSub,thisDir);
        else
            rp = [rp;dlmread(fullfile(baseDir,thisSub,thisDir,w.name))];
            
        end
        
    end % going through this subjects directories
    
    max_trans(s) = max(max(rp(:,1:3)));
    max_rot(s) = max(max(rp(:,4:6)));
    avg_trans(s) = mean(mean(rp(:,1:3)));
    avg_rot(s) = mean(mean(rp(:,4:6)));
    avg_trans_first(s) = mean(mean(rp(1:options.first,1:3)));
    avg_trans_last(s) = mean(mean(rp(end-options.last:end,1:3)));
    avg_rot_first(s) = mean(mean(rp(1:options.first,4:6)));
    avg_rot_last(s) = mean(mean(rp(end-options.last:end,4:6)));

    
    fprintf('%s: maximum translation %.2f mm, maximum rotation %.2f radians (%.1f degrees).\n', thisSub, max_trans(s), max_rot(s), max_rot(s)*(180/pi));
    
    
    if options.graph_each > 0
      figure
      
      subplot(2,1,1)
      plot(rp(:,1:3))
      xlabel('Scan number')
      ylabel('mm')
      set(gca,'XLim',[0 size(rp,1)])
      
      curry = get(gca,'YLim');
      if curry(1) > -3; curry(1) = -3; end
      if curry(2) < 3; curry(2) = 3;, end
      set(gca,'YLim', curry);
      
      legend('X translation','Y translation','Z translation','location','NorthEast')
      title(sprintf('Subject %s, run %s',thisSub,thisDir))
      
      
      subplot(2,1,2)
      plot(rp(:,4:6))
      xlabel('Scan number')
      ylabel('radians')
      legend('Pitch','Roll','Yaw','location','NorthEast')
      set(gca,'XLim',[0 size(rp,1)])
      title(sprintf('Subject %s, run %s',thisSub,thisDir))              
    end
end % looping through subjects

fprintf('\n')


if length(subjects) > 1
  fprintf('All subjects: maximum translation of %.2f mm (mean = %.2f, SD = %.2f).\n', max(max_trans), mean(max_trans), std(max_trans));
  fprintf('All subjects: maximum rotation of %.2f radians (mean = %.2f, SD = %.2f).\n', max(max_rot), mean(max_rot), std(max_rot));
  fprintf('\n')
  fprintf('All subjects: average translation of %.5f mm (SD = %.5f).\n', mean(avg_trans), std(avg_trans));
  fprintf('All subjects: average rotations of %.5f radians (SD = %.5f).\n', mean(avg_rot), std(avg_rot));
end

if options.graph_total > 0
  figure
  
  subplot(1,2,1)
  hist(max_trans)
  title('Maximum translation displacements (mm)')
  
  subplot(1,2,2)
  hist(max_rot)
  title('Maximum rotation displacements (radians)')

   
end


if options.save_vars > 0
  save viewmotion_vars max_trans max_rot avg_trans avg_rot avg_trans_first avg_trans_last avg_rot_first avg_rot_last options
end
