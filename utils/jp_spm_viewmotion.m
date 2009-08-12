function jp_spm_viewmotion(directory, cfg)
%JP_SPM_VIEWMOTION Look at motion parameters from realignment.
%
% JP_SPM_VIEWMOTION([DIRECTORY],[CFG]) plots motion parameters
% calculated during realignment.  If DIRECTORY isn't specified you
% are prompted to choose one.
%
% CFG has the following options:
%
%  savename  if specified, *.png image is saved in DIRECTORY
%  closefig  if 1, close the figure that is opened

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


if nargin < 2 || isempty(cfg)
  cfg = struct();
end

if nargin < 1 || isempty(directory)
  directory = spm_select(1, 'Dir', 'Select directory containing rp_*.txt file');
end

if ~isfield(cfg, 'savename')
  cfg.savename = '';
end

if ~isfield(cfg, 'closefig')
  cfg.closefig = 0;
end


% get the realignment file and read the parameters
rpfile = spm_select('FpList', directory, '^rp_.*\.txt');

if size(rpfile,1) > 1
  fprintf('More than 1 rp_*.txt file found:\n');
  for i=1:size(rpfile,1)
    fprintf('\t%s\n', rpfile(i,:));
  end
  
  fprintf('Using the first.\n');
  rpfile = strtok(rpfile(1,:));
end


rp = dlmread(rpfile);
nscan = size(rp,1);

f1 = figure('position', [47 471 663 431], 'color', 'w');

% translation
subplot(2,1,1);
plot(rp(:,1:3), 'linewidth', 1.5);
legend('X', 'Y', 'Z', 'location', 'SouthEastOutside');
ylabel('Translations (mm)')
title(sprintf('Movement parameters for %s', strrep(directory, '_', '\_')))
set(gca, 'XLim', [1 nscan]);
hold on
plot([1 nscan], [2 2], 'k:', 'color', [.5 .5 .5], 'linewidth', 1.5);
plot([1 nscan], [-2 -2], 'k:', 'color', [.5 .5 .5], 'linewidth', 1.5);
xlabel('Scan')

if max(max(abs(rp(:,1:3)))) < 2
  set(gca,'Ylim', [-2.2 2.2]);
end



% rotation
subplot(2,1,2);
plot(rp(:,4:6), 'linewidth', 1.5);
legend('Pitch', 'Roll', 'Yaw','location', 'SouthEastOutside');
ylabel('Rotations (radians)')
set(gca,'XLim', [1 nscan]);
xlabel('Scan')

if ~isempty(cfg.savename)
  print('-dpng', '-r100', fullfile(directory,cfg.savename));
end

if cfg.closefig
  close(f1);
end


