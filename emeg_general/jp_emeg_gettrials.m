function [trl,events,allevents] = jp_emeg_gettrials(y, cfg)
%JP_EMEG_GETTRIALS Get trials onsets and offsets.
%
% TRIALS = JP_EMEG_GETTRIALS(Y,CFG) returns a FieldTrip-style trial
% structure (see DEFINETRIAL) from a trigger channel Y.
%
% [TRIALS,E,ALLEVENTS] = JP_EMEG_GETTRIALS(Y,CFG) returns the filtered
% events structure E and/or all events prior to filtering (ALLEVENTS).
%
%
% The CFG structure must have trigger(s) and sampling frequency specified:
%   cfg.triggers = [10];
%   cfg.fs = 250; % in Hz
%
% CFG also has the following optional arguments:
%
%   minduration    if specified, minimum duration of a trial in seconds (default [])
%   maxduration    if specified, maximum duration of a trial in seconds (default [])
%   previousvalues use with fromprevious; indicates acceptable values prior to trigger (default 0)
%   fromprevious   num samples prior to trial; if > 0, whether a previous value is required (default 0)
%   prestim        time (seconds) before trigger included in trial
%   poststim       time (seconds) after trigger included in trial
%   plot_events    if 1 plot trigger channel and events  (default 0)
%   plot_trials    if 1 plot trials (which may be longer than events (default 0)
%   plot           if 1 plot both events and trials (default 0)
%   intermediate   number of possible intermediate samples (see below) (default 2)
%
% Setting cfg.fromprevious = 0 doesn't check for any preceding values.
% Setting to > 0 checks for ANY preceding values (in case some intermediate
% values may appear due to interpolation).  So cfg.fromprevious = 2 would
% give trials where the 1st sample before trigger value OR the 2nd sample
% before the trigger value were contained in cfg.previousvalues.
%
% Sometimes trigger values take more than 1 sample to appear.  For example,
% for a trigger of 128, you might expect the trigger channel to look like
% this:
%
%  0 0 0 0 0 0 128 128 128 128
%
% However, sometimes you will instead see:
%
%  0 0 0 0 0 0 93  128 128 128
%
% Setting cfg.intermediate > 0 will find these occurances and set them to
% the following number (in the above case the 93 would be set to 128).
%
%
% Example with test signal:
%   x = 1:1000;
%   y1 = (sin(x/15)>.5)*10;
%   y2 = (sin(x/2)>.5) * 5;
%   y2(1:500) = zeros(1,500);
%   y = y1+y2;
% 
%   cfg = struct('triggers', [10], 'plot', 1, 'fromprevious', 1);
%   trials = jp_meg_gettrials(y, cfg);
%
%
% Example with neuromag data to get rid of participant keypresses by using
% only first 4 channels:
%
%   % rawchannels is: /opt/neuromag/meg_pd_1.2/rawchannels.m
%   [B,sf] = rawchannels('myfile.fif', {'STI001' 'STI002' 'STI003''STI004'});
%
%   B(B>0) = 1; % values are 0 or 5, make it binary
% 
%   % for each row, get the values encoded by that channel
%   for k=1:size(B,1)
%      B(k,B(k,:)>0) = 2^(k-1);
%   end
% 
%   % add up these channels to get the new trigger channel
%   sti101_new = sum(B,1);
% 
%   % set configuration for trials
%   cfg.triggers = [4 9]; 
%   cfg.prestim = 1;
%   cfg.poststim = 4;
%   cfg.plot = 1;
%   [trials,events] = jp_meg_gettrials(sti101_new, cfg);
%
% 
% Requires JP_EMEG_PLOTEVENTS and JP_EMEG_PLOTTRIALS for plotting.
%
% Jonathan Peelle
% MRC CBU
% April 2009


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Required values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(cfg, 'triggers') || isempty(cfg.triggers)
    error('cfg.triggers required')
end

if ~isfield(cfg, 'fs') || isempty(cfg.fs)
    error('cfg.fs (sampling frequency) required')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other optional values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(cfg, 'minduration')
    cfg.minduration = [];
end

if ~isfield(cfg, 'maxduration')
    cfg.maxduration = [];
end

if ~isfield(cfg, 'previousvalues')
    cfg.previousvalues = [0];
end

if ~isfield(cfg, 'fromprevious') || isempty(cfg.fromprevious)
    cfg.fromprevious = 2;
end

if ~isfield(cfg, 'plot') || isempty(cfg.plot)
    cfg.plot = 0;
end

if ~isfield(cfg,'plot_events') || isempty(cfg.plot_events)
    cfg.plot_events = 0;
end

if ~isfield(cfg,'plot_trials') || isempty(cfg.plot_trials)
    cfg.plot_trials = 0;
end

if ~isfield(cfg,'prestim') || isempty(cfg.prestim)
    cfg.prestim = 0;
end

if ~isfield(cfg, 'poststim') || isempty(cfg.poststim)
    cfg.poststim = 0;
end
    
if ~isfield(cfg, 'intermediate') || isempty(cfg.intermediate)
    cfg.intermediate = 2;
end


if cfg.plot>0
   cfg.plot_events = 1;
   cfg.plot_trials = 1;
end


triggers = cfg.triggers;
minduration = cfg.minduration;
maxduration = cfg.maxduration;
fromprevious = cfg.fromprevious;
previousvalues = cfg.previousvalues;
prestim = cfg.prestim;
poststim = cfg.poststim;
fs = cfg.fs;
intermediate = cfg.intermediate;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get rid of intermediate values using circshift
% Thanks to Danny Mitchell for this excellent method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:intermediate
    offending = find(diff(y).*circshift(diff(y),[1 1]));
    y(offending) = y(offending+1);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get events
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

events = struct();

ev = 1; % event index, start at 1

% first event starts with trial - this should get thrown away anyway
events(1).startsample = 1;
events(1).value = NaN;
events(1).origevent = 1;

% Any time y changes value, it's an event!
for s=(fromprevious+2):length(y)
    if y(s)~=y(s-1)
        % new event---mark last sample of old event...
        events(ev).endsample = s-1;
        events(ev).endtime = (s-1)/fs;
        events(ev).duration = (events(ev).endsample - events(ev).startsample)/fs;
        
        %...and onset of new event
        ev = ev + 1;
        events(ev).value = y(s);
        events(ev).startsample = s;
        events(ev).starttime = s/fs;
        events(ev).origevent = ev; % once we filter, we can still match up to original
        
        if fromprevious>0
            events(ev).prev_values = y((s-1-(fromprevious-1)):s-1);
        end        
    end % checking for new event
end

allevents = events; % keep an unfiltered copy

fprintf('%i total events found. Filtering...', length(events))



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter events according to whatever criteria are set in cfg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% first get the ones that have the right trigger values
events = events(ismember([events.value], triggers));

% filter by minduration
if ~isempty(minduration)
    events = events([events.duration]>=minduration);
end

% filter by maxduration
if ~isempty(maxduration)
    events = events([events.duration]<=maxduration);
end

% filter by fromprevious
if fromprevious > 0
    good = ones(1,length(events));
    for i=1:length(events)
       if ~any(ismember(events(i).prev_values, previousvalues))
           good(i) = 0;
       end
    end
    
    events = events(good==1);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make trial (Fieldtrip trl) structure: N-by-3 array with start sample, end
% sample, and offset (in samples, see DEFINETRIAL)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if length(events)==0 || isempty(events)
    warning('0 events found.')
    trl = [];
else
    trl = zeros(length(events),3);
    trl(:,1) = [events.startsample]-ceil(prestim*fs);
    trl(:,2) = [events.startsample]+ceil(poststim*fs);
    trl(:,3) = 0 - ceil(prestim*fs);
    fprintf('done. %i events found.\n\n', length(events))
end


% check to make sure last trial doesn't end after the file does
if ~isempty(trl) && (trl(end,2) >= length(y))
    fprintf('WARNING: Last trial ends at sample %i, but you only have %i samples in your data.\n', trl(end,2), length(y));    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot events and trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if cfg.plot_events > 0
    jp_emeg_plotevents(y,events,cfg);
end


if cfg.plot_trials > 0 && ~isempty(trl)
    jp_emeg_plottrials(y,trl,cfg);
end



