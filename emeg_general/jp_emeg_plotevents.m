function jp_emeg_plotevents(y, events, cfg)
%JP_EMEG_PLOTEVENTS Plot events overlaid on a trigger channel.
%
% JP_EMEG_PLOTEVENTS(Y,EVENTS,CFG) plots events over a trigger channel Y.
% EVENTS are in the format returned by JP_EMEG_GETTRIALS.
%
% CFG has two required fields:
%   fs        the sampling frequency of the data
%   triggers  trigger values to be plotted
%
%
% Jonathan Peelle
% MRC CBU
% April 2009



fs = cfg.fs;
triggers = cfg.triggers;


x = (1:length(y))/fs;

colors = {'b' 'r' 'g' 'c' 'm' 'k'};

figure('name', sprintf('Events for [%s]', num2str(triggers)))

plot(x, y, 'k-', 'Color', [.7 .7 .7], 'LineWidth', 1);
ax1 = gca;
ylabel('Signal value')

set(gca,'XLim',[0 max(x)]);

for i=1:length(triggers)
    t = triggers(i);
    tmpe = events([events.value]==t);

    for j=1:length(tmpe)
        h = line([tmpe(j).startsample/fs tmpe(j).endsample/fs], [triggers(i) triggers(i)], 'color', colors{i}, 'linewidth', 3);
        hold on
    end
end
set(gca,'YLim', [0 max(y)+1]);
ylabel(sprintf('Events for [%s]', num2str(triggers)))
xlabel('Time (s)')
