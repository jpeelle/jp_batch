function cfg = jp_setcfg(cfg, fn, defs_functions)
%JP_SETCFG Set default values for cfg.
%
% CFG = JP_SETCFG(CFG, [FNAME], [{DEFS_FUNCTIONS}]) Sets all CFG
% values, or, optionally, only for a particular field FNAME.
%
% DEFS_FUNCTIONS allows you to specify the name of the function(s)
% where the defaults come from.
%
% If not specified, DEFS_FUNCTIONS is set to 'jp_defaults'.
%
% These functions can be anywhere in your matlab path.

% Jonathan Peelle
% MRC Cognition and Brain Sciences Unit



if nargin < 3 || isempty(defs_function)
  defs_functions = 'jp_defaults';
end

if nargin < 2
  fn = [];
end

if nargin < 1
  cfg = struct();
end


% make sure defs_function is a cell array
if ischar(defs_functions)
  defs_functions = cellstr(defs_functions);
end


% for each function listed, fill cfg
for f = 1:length(defs_functions)
  % Get the default values from the defs_function
  defs = eval([defs_functions{f} '();']);
  cfg = fillit(cfg, defs, fn);
end

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


