function S = jp_addanalysis(S, a);
%JP_ADDANALYSIS Add an analysis stage to an S structure.
%
% S = JP_ADDANALYSIS(S, stagename) appends the specified stage to
% the list in S.  For example:
%
% S = [];
% S = jp_addanalysis(S, 'jp_spm8_realign');
% S = jp_addanalysis(S, 'jp_spm8_coregister');

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit


if ~isfield(S, 'analysis') || isempty(S.analysis)
  n = 1;
else
  n = length(S.analysis) + 1;
end


S.analysis(n).name = a;
