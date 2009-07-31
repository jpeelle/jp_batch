function S = jp_init(S);
%JP_INIT Initialize S structure for study analysis.
%
% S = JP_INIT(S) sets up all the needed fields of the structure S
% prior to running with JP_RUN. Default values are taken from
% JP_DEFAULTS and filled in, unless a user-specified value already
% exists.
%
% Defaults from any other function can be used by setting the
% options prior to running JP_INIT:
%
%  S.cfg.options.defsfunction = 'my_defaults';
%
%
% Use JP_ADDSUBJECT to add subjects to S.
%
% See also JP_BATCH, JP_DEFAULTS, JP_RUN.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure basic required fields exist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(S, 'subjdir') || isempty(S.subjdir)
  error('You must specify S.subjdir, the directory where your subject data lives.')
else
  if ~isdir(S.subjdir)
    fprintf('WARNING: %s not found.\n', S.subjdir);
  end
end


if ~isfield(S, 'cfg')
  S.cfg = [];
end

if ~isfield(S.cfg, 'options')
  S.cfg.options = [];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sort out the defaults function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(S.cfg.options, 'defsfunction') || isempty(S.cfg.options.defsfunction)
  S.cfg.options.defsfunction = 'jp_defaults';
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fill in default values for stages requested (unless not specified yet)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(S, 'analysis')
  S.cfg = jp_setcfg(S.cfg, 'options');
  for i=1:length(S.analysis)
    S.cfg = jp_setcfg(S.cfg, S.analysis(i).name, S.cfg.options.defsfunction);
  end
else
  S.cfg = jp_setcfg(S.cfg);
end


