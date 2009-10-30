function S = jp_spm8_viewbadscans(S, subnum)
%JP_SPM8_VIEWBADSCANS Look at distribution of bad scans over a study.
%
% JP_SPM8_VIEWBADSCANS will let you know, for a specified threshold, how
% many scans for each subject will get rejected. Thresholds are specified
% separately for each of the 6 realignment parameters and the time
% difference; see JP_SPM8_GETBADSCANS for values and defaults.
%
% See JP_DEFAULTS_SPMFMRI for all defaults.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


% If not specified, loop through all subjects
if nargin < 2
  subnum = 1:length(S.subjects);
end

% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);


% for every subject, get their data for all sessions, and then
% threshold


D = struct();

for s=1:length(S.subjects)
  fprintf('Getting data for subject %s (%i/%i)...\n', S.subjects(s).name, s, length(S.subjects));
  
  subjdir = fullfile(S.subjdir, S.subjects(s).name);
  sessions = jp_getsessions(S, s);
  
  D(s).rp = [];
  D(s).rpdiff = [];
  D(s).globals = [];
  D(s).slicediff = [];
  D(s).td = [];
  D(s).td_scaled = [];
  
  for k=1:length(S.subjects(s).sessions)
    
    sessdir = fullfile(subjdir, S.subjects(s).sessions(k).name);
    
    timedifffile = fullfile(sessdir, 'timediff.mat');
    rpfile = spm_select('fplist', sessdir, '^rp_.*\.txt');
    
    % get movement parameters
    if ~exist(rpfile)
      fprintf('rp_ file %s not found, skipping\n', rpfile);
    else
      D(s).rp = [D(s).rp; dlmread(rpfile)];
      D(s).rpdiff = [D(s).rpdiff; diff(dlmread(rpfile))];
    end
    
    
    % get tsdiff ana information
    if ~exist(timedifffile)
      fprintf('timediff file %s not found, skipping\n', timedifffile);
    else
      load(timedifffile);
      D(s).globals = [D(s).globals; globals];
      D(s).slicediff = [D(s).slicediff; slicediff];
      D(s).td = [D(s).td; td];
      D(s).td_scaled = [D(s).td_scaled; td/mean(globals)];
    end
    
    
  end
end

fprintf('done.\n\n');


%only look at subjects that have both rp and tsdiff
badsubs = [];
fprintf('Only looking at subjects that have both rp* and timediff.mat files...\n');
for s=1:length(S.subjects)
    if isempty(D(s).rp) || isempty(D(s).td_scaled)
        badsubs = [badsubs s];
    end
end

goodsubs = setdiff(1:length(S.subjects), badsubs);

fprintf('Using %i subjects (ignoring %i).\n', length(goodsubs), length(badsubs));

D = D(goodsubs);


% for holding all the scans
badscans = zeros(length(S.subjects), 7); % 6 movement parameters + timediff

nbins = 30;

totalscans = zeros(1,length(S.subjects));
totalbad = zeros(1,length(S.subjects));
rpthresh = [cfg.trans_x cfg.trans_y cfg.trans_z cfg.rot_x cfg.rot_y cfg.rot_z];

for g=1:length(goodsubs)
  
  s = goodsubs(g);
  
  subjbad = [];
  rpdiff = D(s).rpdiff;
  timediff = D(s).td_scaled;
  allbad{s} = zeros(size(D(s).rpdiff,1),7);
  
  for r=1:6
    badscans(s,r) = sum(abs(rpdiff(:,r)) > rpthresh(r));
    whichrpbad = find(abs(rpdiff(:,r)) > rpthresh(r))';
    allbad{s}(whichrpbad,r) = 1;
    subjbad = [subjbad whichrpbad];
  end
    
  subjbad = [subjbad find(timediff > cfg.timediff)'];
  badscans(s,7) = sum(timediff > cfg.timediff);
  allbad{s}(find(timediff > cfg.timediff), 7) = 1;
  
  
  subjbad = unique(subjbad);
  totalbad(s) = length(subjbad);
  totalscans(s) = size(D(s).rp,1);
  
  fprintf('%s: %i/%i scans (%.1f%%) counted as bad.\n', S.subjects(s).name, length(subjbad), totalscans(s), 100*(length(subjbad)/totalscans(s)));
  
  if cfg.ploteachsubject > 0
    figure('color', 'w', 'position',  [360 166 672 756], 'name', S.subjects(s).name)
    
    % ------------ translations ----------------------------
    subplot(4,2,1)
    [n,p] = hist(rpdiff(:,1), nbins);
    bar(p,n,'facecolor', [.7 .7 .7]);
    hold on
    % plot the rejection limits
    x = [cfg.trans_x cfg.trans_x];
    y = [0 max(n)];
    plot(x,y,'r-','linewidth',2);
    plot(-1*x,y,'r-','linewidth',2);
    title(sprintf('X Translations (%i bad)', badscans(s,1)))
    xlabel('X translation difference (mm)')
    ylabel('# scans')
    
    
    subplot(4,2,3)
    [n,p] = hist(rpdiff(:,2), nbins);
    bar(p,n,'facecolor', [.7 .7 .7]);
    hold on
    % plot the rejection limits
    x = [cfg.trans_y cfg.trans_y];
    y = [0 max(n)];
    plot(x,y,'r-','linewidth',2);
    plot(-1*x,y,'r-','linewidth',2);
    title(sprintf('Y Translations (%i bad)', badscans(s,2)))
    xlabel('Y translation difference (mm)')
    ylabel('# scans')
    
    
    subplot(4,2,5)
    [n,p] = hist(rpdiff(:,3), nbins);
    bar(p,n,'facecolor', [.7 .7 .7]);
    hold on
    % plot the rejection limits
    x = [cfg.trans_z cfg.trans_z];
    y = [0 max(n)];
    plot(x,y,'r-','linewidth',2);
    plot(-1*x,y,'r-','linewidth',2);
    title(sprintf('Z Translations (%i bad)', badscans(s,3)))
    xlabel('Z translation difference (mm)')
    ylabel('# scans')
    
    
    % ------------ rotations ----------------------------
        
    subplot(4,2,2)
    [n,p] = hist(rpdiff(:,4), nbins);
    bar(p,n,'facecolor', [.7 .7 .7]);
    hold on
    % plot the rejection limits
    x = [cfg.rot_x cfg.rot_x];
    y = [0 max(n)];
    plot(x,y,'r-','linewidth',2);
    plot(-1*x,y,'r-','linewidth',2);
    title(sprintf('X Rotations (%i bad)', badscans(s,4)))
    xlabel('X Rotations difference (rad)')
    ylabel('# scans')
    
    subplot(4,2,4)
    [n,p] = hist(rpdiff(:,5), nbins);
    bar(p,n,'facecolor', [.7 .7 .7]);
    hold on
    % plot the rejection limits
    x = [cfg.rot_y cfg.rot_y];
    y = [0 max(n)];
    plot(x,y,'r-','linewidth',2);
    plot(-1*x,y,'r-','linewidth',2);
    title(sprintf('Y Rotations (%i bad)', badscans(s,5)))
    xlabel('Y Rotations difference (rad)')
    ylabel('# scans')
    
    
    subplot(4,2,6)
    [n,p] = hist(rpdiff(:,6), nbins);
    bar(p,n,'facecolor', [.7 .7 .7]);
    hold on
    % plot the rejection limits
    x = [cfg.rot_z cfg.rot_z];
    y = [0 max(n)];
    plot(x,y,'r-','linewidth',2);
    plot(-1*x,y,'r-','linewidth',2);
    title(sprintf('Z Rotations (%i bad)', badscans(s,6)))
    xlabel('Z Rotations difference (rad)')
    ylabel('# scans')
    
    subplot(4,2,7)
    [n,p] = hist(timediff, nbins);
    bar(p,n,'facecolor', [.7 .7 .7]);
    hold on
      % plot the rejection limits
    x = [cfg.timediff cfg.timediff];
    y = [0 max(n)];
    plot(x,y,'r-','linewidth',2);
    title(sprintf('Time difference (%i bad)', badscans(s,7)))
    xlabel('Time difference (a.u.)')
    ylabel('# scans')
    
    
    subplot(4,2,8)
    imagesc(allbad{s})
    colormap(flipud(gray))
    ylabel('Scan #')
    xlabel('parameter (6 motion + timediff)')
    set(gca, 'XTickLabel', {'x' 'y' 'z' 'rx' 'ry' 'rz' 'td'})
    
    % some text
    ax = axes('position', [0 0 1 1], 'Visible', 'off');
    text(.05,.05, sprintf('%i unique scans rejected out of %i total (%.1f %%).', totalbad(s), totalscans(s), 100*(totalbad(s)/totalscans(s))), 'fontsize', 14);
    
    
  end
end % going through subjects again to figure out how many scans would be kept



% Plot distibution over all subjects
figure('color', 'w', 'name', 'group totals by parameter')
params = {'X Translations' 'Y Translations' 'Z translations' 'X rotations' 'Y rotations' 'Z rotations' 'Timediff'};
whereplot = [1 3 5 2 4 6 7];
for i=1:7
  subplot(4,2,whereplot(i))
  hist(badscans(:,i))
  title(params{i});
  xlabel('# scans rejected')
  ylabel('# subjects')
end
  





figure('color', 'w', 'name', 'group statistics')

allrpdiff = cat(1,D.rpdiff);
alltrans = allrpdiff(:,1:3);
allrots = allrpdiff(:,4:6);
alltsdiff = cat(1,D.td_scaled);


subplot(1,2,1)
[n,p] = hist(totalbad);
bar(p,n,'facecolor', [ 0.0431 0.5176 0.7804]);
xlabel('# scans bad')
ylabel('# subjects')
title('Histogram of # scans bad per subject')

ax2 = axes('position', [0 0 1 1], 'Visible', 'off');
text(.5,.7, sprintf('On average %.1f scans bad per subject\n(with current threshold).', mean(totalbad)), 'fontsize', 12);
text(.5,.6, sprintf('Over all subjects, %i/%i scans\n(%.1f %%) bad.', sum(totalbad), sum(totalscans), 100*(sum(totalbad)/sum(totalscans))), 'fontsize', 12);


% print average and SD 


fprintf('\nTranslations X diff:\n');
fprintf('\tmean: %.3f mm\n', mean(alltrans(:,1)));
fprintf('\tstdev: %.3f mm\n', std(alltrans(:,1)));
fprintf('\tmean + 3 SD: %.3f mm\n', mean(alltrans(:,1)) + 3*std(alltrans(:,1)));
fprintf('\tmean - 3 SD: %.3f mm\n', mean(alltrans(:,1)) - 3*std(alltrans(:,1)));

fprintf('\tmean + 3.5 SD: %.3f mm\n', mean(alltrans(:,1)) + 3.5*std(alltrans(:,1)));
fprintf('\tmean - 3.5 SD: %.3f mm\n', mean(alltrans(:,1)) - 3.5*std(alltrans(:,1)));

fprintf('\tmean + 4 SD: %.3f mm\n', mean(alltrans(:,1)) + 4*std(alltrans(:,1)));
fprintf('\tmean - 4 SD: %.3f mm\n', mean(alltrans(:,1)) - 4*std(alltrans(:,1)));


xlabel('Translation Y diff (mm)')
ylabel(' # scans')
fprintf('\nTranslations Y diff:\n');
fprintf('\tmean: %.3f mm\n', mean(alltrans(:,2)));
fprintf('\tstdev: %.3f mm\n', std(alltrans(:,2)));
fprintf('\tmean + 3 SD: %.3f mm\n', mean(alltrans(:,2)) + 3*std(alltrans(:,2)));
fprintf('\tmean - 3 SD: %.3f mm\n', mean(alltrans(:,2)) - 3*std(alltrans(:,2)));

fprintf('\tmean + 3.5 SD: %.3f mm\n', mean(alltrans(:,2)) + 3.5*std(alltrans(:,2)));
fprintf('\tmean - 3.5 SD: %.3f mm\n', mean(alltrans(:,2)) - 3.5*std(alltrans(:,2)));

fprintf('\tmean + 4 SD: %.3f mm\n', mean(alltrans(:,2)) + 4*std(alltrans(:,2)));
fprintf('\tmean - 4 SD: %.3f mm\n', mean(alltrans(:,2)) - 4*std(alltrans(:,2)));



fprintf('\nTranslations Z diff:\n');
fprintf('\tmean: %.3f mm\n', mean(alltrans(:,3)));
fprintf('\tstdev: %.3f mm\n', std(alltrans(:,3)));
fprintf('\tmean + 3 SD: %.3f mm\n', mean(alltrans(:,3)) + 3*std(alltrans(:,3)));
fprintf('\tmean - 3 SD: %.3f mm\n', mean(alltrans(:,3)) - 3*std(alltrans(:,3)));

fprintf('\tmean + 3.5 SD: %.3f mm\n', mean(alltrans(:,3)) + 3.5*std(alltrans(:,3)));
fprintf('\tmean - 3.5 SD: %.3f mm\n', mean(alltrans(:,3)) - 3.5*std(alltrans(:,3)));

fprintf('\tmean + 4 SD: %.3f mm\n', mean(alltrans(:,3)) + 4*std(alltrans(:,3)));
fprintf('\tmean - 4 SD: %.3f mm\n', mean(alltrans(:,3)) - 4*std(alltrans(:,3)));




%% rotations -----------------------

fprintf('\nRotations X diff:\n');
fprintf('\tmean: %.5f rad\n', mean(allrots(:,1)));
fprintf('\tstdev: %.5f rad\n', std(allrots(:,1)));
fprintf('\tmean + 3 SD: %.5f rad\n', mean(allrots(:,1)) + 3*std(allrots(:,1)));
fprintf('\tmean - 3 SD: %.5f rad\n', mean(allrots(:,1)) - 3*std(allrots(:,1)));

fprintf('\tmean + 3.5 SD: %.5f rad\n', mean(allrots(:,1)) + 3.5*std(allrots(:,1)));
fprintf('\tmean - 3.5 SD: %.5f rad\n', mean(allrots(:,1)) - 3.5*std(allrots(:,1)));

fprintf('\tmean + 4 SD: %.5f rad\n', mean(allrots(:,1)) + 4*std(allrots(:,1)));
fprintf('\tmean - 4 SD: %.5f rad\n', mean(allrots(:,1)) - 4*std(allrots(:,1)));




fprintf('\nRotations Y diff:\n');
fprintf('\tmean: %.5f rad\n', mean(allrots(:,2)));
fprintf('\tstdev: %.5f rad\n', std(allrots(:,2)));
fprintf('\tmean + 3 SD: %.5f rad\n', mean(allrots(:,2)) + 3*std(allrots(:,2)));
fprintf('\tmean - 3 SD: %.5f rad\n', mean(allrots(:,2)) - 3*std(allrots(:,2)));

fprintf('\tmean + 3.5 SD: %.5f rad\n', mean(allrots(:,2)) + 3.5*std(allrots(:,2)));
fprintf('\tmean - 3.5 SD: %.5f rad\n', mean(allrots(:,2)) - 3.5*std(allrots(:,2)));

fprintf('\tmean + 4 SD: %.5f rad\n', mean(allrots(:,2)) + 4*std(allrots(:,2)));
fprintf('\tmean - 4 SD: %.5f rad\n', mean(allrots(:,2)) - 4*std(allrots(:,2)));



fprintf('\nRotations Z diff:\n');
fprintf('\tmean: %.5f rad\n', mean(allrots(:,3)));
fprintf('\tstdev: %.5f rad\n', std(allrots(:,3)));
fprintf('\tmean + 3 SD: %.5f rad\n', mean(allrots(:,3)) + 3*std(allrots(:,3)));
fprintf('\tmean - 3 SD: %.5f rad\n', mean(allrots(:,3)) - 3*std(allrots(:,3)));

fprintf('\tmean + 3.5 SD: %.5f rad\n', mean(allrots(:,3)) + 3.5*std(allrots(:,3)));
fprintf('\tmean - 3.5 SD: %.5f rad\n', mean(allrots(:,3)) - 3.5*std(allrots(:,3)));

fprintf('\tmean + 4 SD: %.5f rad\n', mean(allrots(:,3)) + 4*std(allrots(:,3)));
fprintf('\tmean - 4 SD: %.5f rad\n', mean(allrots(:,3)) - 4*std(allrots(:,3)));


meanalltsdiff = mean(alltsdiff);
sdalltsdiff = std(alltsdiff);
fprintf('TSDIFF:\n');
fprintf('\tmean: %.3f\n', meanalltsdiff);
fprintf('\tstd: %.3f\n', sdalltsdiff);
fprintf('\tmean + 3SD: %.3f\n', meanalltsdiff + 3*sdalltsdiff);

fprintf('\tmean + 3.5 SD: %.3f\n', meanalltsdiff + 3.5*sdalltsdiff);

fprintf('\tmean + 4 SD: %.3f\n', meanalltsdiff + 4*sdalltsdiff);


fprintf('\n-----------------------------------------------------------------------------\n');
fprintf('With current thresholds, %i unique scans rejected out of %i total (%.1f%%).\n', sum(totalbad), sum(totalscans), 100*(sum(totalbad)/sum(totalscans)))
fprintf('(You can adjust thresholds in S.cfg.jp_spm8_viewbadscans)\n\n')

% figure('position', [0 









