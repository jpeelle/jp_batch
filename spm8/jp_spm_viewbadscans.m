function D = jp_spm_viewbadscans(S);
%JP_SPM_VIEWBADSCANS Look at distribution of bad scans over a
%study.
%
% See JP_DEFAULTS_SPMFMRI for defaults.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);


% for every subject, get their data for all sessions, and then
% threshold


D = struct();

for s=1:length(S.subjects)
  fprintf('Subject %s...\n', S.subjects(s).name);
  
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
        D(s).rpdiff = [D(s).rpdiff; diff(D(s).rp)];
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


badsubs = [];
for s=1:length(S.subjects)
    if isempty(D(s).rp) || isempty(D(s).td_scaled)
        badsubs = [badsubs s];
    end
end

goodsubs = setdiff(1:length(S.subjects), badsubs);

fprintf('Using %i subjects (ignoring %i).\n', length(goodsubs), length(badsubs));

D = D(goodsubs);

nbins = 50;

figure('position', [0 620 1236 277], 'color', 'w')
subplot(1,3,1)
rpdiff = vertcat(D.rpdiff);
trans = rpdiff(:,1:3);
trans = reshape(trans, prod(size(trans)), 1);
[n,p] = hist(trans, nbins);
bar(p,n, 'facecolor', [.6 .6 .6]);
ylabel('Frequency (# of scans)')
xlabel('Translation difference (mm)')
trans_mean = mean(trans);
trans_sd = std(trans);

subplot(1,3,2)
rot = rpdiff(:,4:6);
rot = reshape(rot, prod(size(rot)), 1);
[n,p] = hist(rot, nbins);
bar(p,n, 'facecolor', [.6 .6 .6]);
xlabel('Rotation difference(rad)')
rot_mean = mean(rot);
rot_sd = std(rot);

subplot(1,3,3);
tsd = vertcat(D.td_scaled);
[n,p] = hist(tsd, nbins);
bar(p,n, 'facecolor', [.6 .6 .6]);
xlabel('Timeseries difference (scaled)')
tsd_mean = mean(tsd);
tsd_sd = std(tsd);



% print info
fprintf('\n\n');
fprintf('Mean translation difference (mm): %.3f (+ 3 SD = %.3f)\n', trans_mean, trans_mean + 3*trans_sd);
fprintf('Mean rotation difference (rad): %.6f (+ 3 SD = %.6f)\n', rot_mean, rot_mean + 3*rot_sd);
fprintf('Mean time series difference: %.3f (+ 3 SD = %.3f)\n', tsd_mean, tsd_mean + 3*tsd_sd);
fprintf('\n')














