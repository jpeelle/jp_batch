function images = jp_getstructimages(prefix, subjdir, subname, structdirs)
%JP_GETSTRUCTIMAGES Get structural images for a subject.
%
% JP_GETSTRUCTIMAGES(PREFIX, SUBJDIR, SUBNAME, STRUCTDIRS)
%
% [Note: now most functions are set up to normally just deal with
% one structural directory and one image per directory, but that
% might change someday.]
%
% $Id$


if nargin < 4
  structdirs = jp_getinfo('structdirs', subjdir, subname);
end

if ischar(structdirs)
  structdirs = cellstr(structdirs);
end


images = [];

for i=1:length(structdirs)
  images = strvcat(images, spm_select('fplist', fullfile(subjdir, subname, structdirs{i}), sprintf('^%s.*\\.nii$',prefix)));
end


