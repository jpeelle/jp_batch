function aap = jp_S2aap(S, aap, sfile, subjects, stages)
%JP_S2AAP Changes S structure into AA-compatabile aap.
%
% JP_S2AAP(S, [AAP]) changes S into appropriate AAP structure. AAP
% is an exisiting AAP structure passed from S.aap which allows the
% setting of any AAP-specific options for various functions.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


if nargin < 5
  stages = 1:length(S.analysis);
end

if nargin < 4
  subjects = 1:length(S.subjects);
end

if nargin < 2
  aap = struct();
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize AA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(S.cfg.options.aapath); % the base AA directory
eval(S.cfg.options.aacmd);     % e.g. aa_ver30



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add the stages
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for now, just run everything through one aa module

aap = aarecipe('aap_parameters_jpdefaults.xml', 'aap_tasklist_jprun.xml');
aap.tasksettings.aamod_jprun.stages = stages;
aap.tasksettings.aamod_jprun.sfile = sfile;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General, acq_details, etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aap.acq_details.root = S.subjdir;
aap.directory_conventions.outputformat = [];
aap.directory_conventions.subject_directory_format = 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add the subjects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(subjects)
  aap.acq_details.subjects(i).mriname = S.subjects(subjects(i)).name;
end
