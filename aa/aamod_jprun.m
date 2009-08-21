function [aap, resp] = aamod_jprun(aap, task, i)
% Use AA (probably subject-wise parallel) to run through an S
% structure.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit

resp = '';

switch task
 case 'domain'
  resp = 'subject';
 case 'report'
  resp='Run S structure using JP_RUN.';
 case 'doit'
  load(aap.tasksettings.aamod_jprun.sfile);
  S.cfg.options.saveS = 0;
  S = jp_run(S, i, aap.tasksettings.aamod_jprun.stages);
end
