function S = jp_addanalysis(S, a, domain);
%JP_ADDANALYSIS Add an analysis stage to an S structure.
%
% S = JP_ADDANALYSIS(S, stagename, [domain]) appends the specified
% stage to the list in S.  For example:
%
% S = [];
% S = jp_addanalysis(S, 'jp_spm8_realign');
% S = jp_addanalysis(S, 'jp_spm8_coregister');
%
% The domain refers to whether this stage can be run at the subject
% level (default) or the study level (for example, creating a
% template for DARTEL).

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit

if nargin < 3
  domain = 'subject';
end


w = which(a);
if isempty(w)
  error('You added stage %s, but this isn''t in your MATLAB path.', a);
end


if ~isfield(S, 'analysis') || isempty(S.analysis)
  n = 1;
else
  n = length(S.analysis) + 1;
end

S.analysis(n).name = a;
S.analysis(n).domain = domain;
