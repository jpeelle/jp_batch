function S = jp_spm5_realign(S, subnum)
%JP_SPM5_REALIGN Realign images using SPM5.
%
% JP_SPM5_REALIGN(S,PREFIX,SUBNUM,[SESSIONNUM])
%
% Options available in S.cfg.jp_spm5_realign include:
%   which_images  for reslicing (default 0 = meanonly)
%
% See JP_DEFAULTS for a full list and defaults.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);


subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

try
  funprefix = S.subjects(subnum).funprefix;
catch
  funprefix = jp_getinfo('funprefix', S.subjdir, subname);
end

try
  fundirs = S.subjects(subnum).fundirs;
catch
  fundirs = jp_getinfo('fundirs', S.subjdir, subname);
end


% log files
[alllog, errorlog, realignlog] = jp_createlogs(subname, S.subjdir, mfilename);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


P = cell(1,length(fundirs));

for d=1:length(fundirs)
  P{d} = jp_getfunimages([cfg.prefix funprefix], S.subjdir, subname, fundirs{d});
  jp_log(realignlog, sprintf('Directory %s: %i images found.\n', fundirs{d}, size(P{d},1)), 1);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Realign
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Get the realignment parameters
jp_log(realignlog, 'Starting spm_realign...', 1);
spm_realign(P, cfg.estimate);
jp_log(realignlog, 'Finished spm_realign.\n', 1);

% Reslice and create a mean image
jp_log(realignlog, 'Starting spm_reslice...', 1);
cfg.write.which = cfg.which_images;
spm_reslice(P, cfg.write)
jp_log(realignlog, 'Finished spm_reslice.\n', 1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jp_log(realignlog, 'Saving output images...');

for d=1:length(fundirs)
  cfg2.savename = sprintf('%s_%s_motionparameters', subname, fundirs{d});
  cfg2.closefig = 1;
  jp_spm_viewmotion(fullfile(S.subjdir, subname, fundirs{d}), cfg2);
end

jp_log(realignlog, 'done.\n');
