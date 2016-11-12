close all;
% Create some data for the two curves to be plotted
x  = [2	5	8	10	12	15]
APS_duration = [21.55538689	90.41947871	143.7096712	194.5885724	214.6740714	306.0827694];
y2 = [0.658147377	0.494505215	0.437154054	0.380084235	0.371309403	0.371070612];
RSS_duration = [2.494119415	5.299381967	6.641248017	7.169114499	7.384207803	7.432964221];
% Create a plot with 2 y axes using the plotyy function
hFig1=figure(1)
set(hFig1, 'Position', [200 200 600 400],'Color',[1 1 1])
plot(x, RSS_duration,'k.-')
hold on
[ax, h1, h2] = plotyy(x, APS_duration, x, y2, 'plot');

% Add title and x axis label
xlabel('Threshold (dBm)','FontSize',18)
% Use the axis handles to set the labels of the y axes
set(get(ax(1), 'YLabel'), 'String', 'Average Duration (sec)','FontSize',18)
set(get(ax(2), 'YLabel'), 'String', 'Length of AP-Sequence','FontSize',18)
set(ax(1),'FontSize',18);
set(ax(2),'FontSize',18);
set(h1,'LineWidth',3,'LineStyle','--');
set(gca,...
    'position',[0.18 0.19 0.75 0.6])
set(h2,'LineWidth',3,'LineStyle','-');
%a = get(gca,'XTickLabel');
%set(gca,'XTickLabel','fontsize',11)