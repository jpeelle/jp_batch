function S = jp_spm8_reslice(S, subnum)
%JP_SPM8_RESLICE reslice images using SPM8.
%
% S = JP_SPM8_RESLICE(S, SUBNUM)
%
% Reslice images (that have probably been realigned
% already). Automatically reslices all functional images for a
% subject.

% Jonathan Peelle
% University of Pennsylvania

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
  fundirs = jp_getsessions(S, subnum);
catch
  fundirs = jp_getinfo('sessions', S.subjdir, subname);
end


% log files
[alllog, errorlog, reslicelog] = jp_createlogs(subname, S.subjdir, mfilename);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


P = cell(1,length(fundirs));

for d=1:length(fundirs)
  P{d} = jp_getfunimages([cfg.prefix funprefix], S.subjdir, subname, fundirs{d}, S.cfg.options.mriext);
  jp_log(reslicelog, sprintf('Directory %s: %i images found.\n', fundirs{d}, size(P{d},1)), 1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reslice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reslice and create a mean image
jp_log(reslicelog, 'Starting spm_reslice...', 1);
cfg.write.which = 2; % reslice all except first
spm_reslice(P, cfg.write)
jp_log(reslicelog, 'Finished spm_reslice.\n', 1);
