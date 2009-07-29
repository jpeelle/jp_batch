function [onsets, durations, weightings] = jp_spm_getev(filename)
%JP_SPM_GETEV Get onset times for explanatory variable.
%
%  ONSETS = JP_GETEV(EVDIR, SUBJECT, CONDITION) returns the onset
%  times for the specified condition.  This will be in units of
%  scans or seconds, and should correspond to info.event_units in
%  the stats directory.
%
%  ONSETS = JP_GETEV(EVDIR, SUBJECT, CONDITION, SESSION) uses the
%  SESSION in the file name.
%
%  [ONSETS, DURATIONS, WEIGHTING] = JP_SPM_GETEV(...) also returns
%  the event durations and weightings, if provided in the EV files.
%
%  If the EV file is one column it is just returned unaltered as the
%  event onsets. If it is 3 columns, it is assumed that the first
%  column has the onset time (s), the second column the event duration
%  (s), and the third column the weighting of the event. This
%  corresponds with the FSL custom file format.
%
%  If the file is only one column, durations will all be set to 0,
%  and weightings will all be set to 1.
%
%  If the EV file only has 2 columns, the weightings are set to 1.
%
%  If the EV file doens't exist, an error is generated. If the file
%  exists but is empty, an empty vector ([]) is returned, although
%  this is almost never what you want, so be careful.
%
%  See also JP_SPM?_MODEL and JP_BATCH.
%
%  $Id$



if ~exist(filename)
  error('EV file %s not found.',filename)
end


d = dlmread(filename);


onsets = d(:,1);

if size(d,2)> 1
  durations = d(:,2);
else
  durations = zeros(size(onsets));
end

if size(d,2)==3
  weightings = d(:,3);
else
  weightings = ones(size(onsets));
end

