function jp_progress(a, b, initialize)
% JP_PROGRESS print a progress bar.
%
% jp_progress;
%
% for i=1:10000
%   jp_progress(i,10000);
% end
%


if nargin < 3
    initialize = 0;
end

if nargin < 2
    b = 0;
end

if nargin < 1
    a = 0;
end


if nargin==0
    initialize = 1;
end


if initialize > 0
    fprintf(['[' repmat(' ', 1, 50) ']\n']);
else
   
    fprintf(repmat('\b',1,53));
    
    ndash = round((a/b)*50);
    nspace = 50-ndash;
    
    fprintf(['[' repmat('-', 1, ndash) repmat(' ', 1, nspace) ']\n']);        
end




