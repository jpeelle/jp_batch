function images = jp_getfunimages(prefix, subjdir, subname, sessions)
%JP_GETFUNIMAGES Get functional images for a subject.
%
% JP_GETFUNIMAGES(PREFIX, SUBJDIR, SUBNAME, [SESSION])
%
% $Id$


% If a session 
if nargin < 4
  sessions = jp_getinfo('fundirs', subjdir, subname);
end

if ischar(sessions)
  sessions = cellstr(sessions);
end

images = [];
  
for i=1:length(sessions)
  thisdir = sessions{i};
  images = strvcat(images, spm_select('fplist', fullfile(subjdir, subname, thisdir), sprintf('^%s.*\\.nii$',prefix)));
end  

