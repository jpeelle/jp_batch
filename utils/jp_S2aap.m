function aap = jp_S2aap(S, aap, subjects, stages)
%JP_S2AAP Changes S structure into AA-compatabile aap.
%
% JP_S2AAP(S, [AAP]) changes S into appropriate AAP structure. AAP
% is an exisiting AAP structure passed from S.aap which allows the
% setting of any AAP-specific options for various functions.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



if nargin < 2
  aap = struct();
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize AA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(S.cfg.options.aapath); % the base AA directory
eval(S.cfg.options.aacmd);     % e.g. aa_ver3




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General, acq_details, etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aap.acq_details.root = S.subjdir;

% (note: make sure all subjects have the same sessions?)

% assumes all subjects have same sessions!
for s=1:length(S.subjects(subjects(1)).sessions.names)
  aap.acq_details.sessions{s} = S.subjects(subjects(1)).sessions(s).name;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add the stages
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add the subjects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other options (not all will be needed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aap.options = S.cfg.aap.options;



