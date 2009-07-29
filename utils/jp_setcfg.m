function cfg = jp_setcfg(cfg, fn, defs_function)
%JP_SETCFG Set default values for cfg.
%
% CFG = JP_SETCFG(CFG, [FNAME], [DEFS_FUNCTION]) Sets all CFG
% values, or, optionally, only for a particular field FNAME.
%
% DEFS_FUNCTION allows you to specify the name of the function
% where the defaults come from (default 'jp_spm_defaults').
%
% $Id$

if nargin < 3 || isempty(defs_function)
  defs_function = 'jp_defaults';
end

if nargin < 2
  fn = [];
end

if nargin < 1
  cfg = struct();
end

% Get the default values from the defs_function
defs = eval([defs_function '();']);


%fprintf('Using default values found in %s\n', which(defs_function))

cfg = fillit(cfg, defs, fn);

end % main function




function X = fillit(X, defs, fnames)
% The goal is to recursively go through all fields; if the field is
% a structure (i.e. contains other fields), go through those;
% otherwise, set the value.

if isempty(fnames)
  fnames = fieldnames(defs);
end

if ischar(fnames)
  fnames = cellstr(fnames);
end

for i=1:length(fnames)
  fn = fnames{i};
   
  if isstruct(defs.(fn))
    if isfield(X, fn)
          X.(fn) =  fillit(X.(fn), defs.(fn), fieldnames(defs.(fn)));
    else 
          X.(fn) = defs.(fn);
    end          
  else  
    if ~isfield(X, fn) || isempty(X.(fn)) 
      X.(fn) = defs.(fn);  
    end
  end
end % going through names

end % fill it


