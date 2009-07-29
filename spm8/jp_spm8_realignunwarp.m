function S = jp_spm8_realignunwarp(S, subnum, sessionnum)
%JP_SPM8_REALIGNUNWARP Realign images using SPM8 realign.
%
% S = JP_SPM8_REALIGNUNWARP(S,SUBNUM,[SESSIONNUM]) uses the realigment
% parameters from realignment (JP_SPM8_REALIGN) to correct for
% magnetic field inhomogeneities. Unwarped images are written out
% with a u.
%
%
% See JP_DEFAULTS for a full list and defaults.
%
% $Id$


if nargin < 3 || isempty(sessionnum)
  sessionnum = 1:length(S.subjects(subnum).sessions);
end



% get any values not specified (if JP_INIT not run previously)
S.cfg = jp_setcfg(S.cfg, mfilename);
cfg = S.cfg.(mfilename);

subname = S.subjects(subnum).name;
subdir = fullfile(S.subjdir, subname);

funprefix = jp_getinfo('funprefix', S.subjdir, subname);

sess = jp_getsessions(S, subnum);
fundirs = sess(sessionnum);

% log files
[alllog, errorlog, realignunwarplog] = jp_createlogs(subname, S.subjdir, 'realignunwarp');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


P = cell(1,length(fundirs));

for d=1:length(fundirs)
  P{d} = jp_getfunimages([cfg.prefix funprefix], S.subjdir, subname, fundirs{d});
  jp_log(realignunwarplog, sprintf('Directory %s: %i images found.\n', fundirs{d}, size(P{d},1)), 1);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start SPM - otherwise UI complaints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm('fmri')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Unwarp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uwflags = struct('which',1); % write out all images

jp_log(realignunwarplog, 'Estimating unwarp...', 1);
ds = spm_uw_estimate(P{d});
jp_log(realignunwarplog, 'done.\n', 1);

jp_log(realignunwarplog, 'Applying unwarp...', 1);
spm_uw_apply(ds, uwflags);
jp_log(realignunwarplog, 'done.\n', 1);
