function jp_emeg_plottrials(y,trl,cfg);
%JP_EMEG_PLOTTRIALS Plot trials overlaid on trigger channel.
%
% JP_EMEG_PLOTTRIALS(Y,TRIALS,CFG) plots events over a trigger channel Y.
% TRIALS are in the format returned by JP_EMEG_GETTRIALS (which matches
% FieldTrip).
%
% CFG has one required field:
%   fs        the sampling frequency of the data
%
% Jonathan Peelle
% MRC CBU
% April 2009


fs = cfg.fs;

x = (1:length(y))/fs;

figure('name', 'Trials')
ymin=0;
ymax = 1.1*max(y);

for i=1:size(trl,1)
    patch([trl(i,1)/fs trl(i,1)/fs trl(i,2)/fs trl(i,2)/fs], [ymin ymax ymax ymin], [1 .771 .749], 'EdgeColor', 'none');
    hold on
end

plot(x, y, 'k-', 'Color', [.6 .6 .6], 'LineWidth', 1);

set(gca,'YLim', [ymin ymax]);
xlabel('Time (s)')
ylabel('Signal value')
