
excelObj = actxserver ('Excel.Application');
fileObj = excelObj.Workbooks.Open('C:\capture\\1.xlsx');
s = excelObj.Worksheets.get('Item', 'graph');

close all;

% figure1 : noise 100% 확률로 발생시 total thoughput
% x = cell2mat(s.Range('B4:B11').Value);
% y = cell2mat(s.Range('C4:E11').Value);
% b = bar(x,y);
% xlim([4 22]);
% ylim([0 800]);
% set(figure(1), 'Position', [200 200 600 400],'Color',[1 1 1])
% set(b(1), 'FaceColor', [0.8, 0.8, 0.8])
% set(b(2), 'FaceColor', [0.4, 0.4, 0.4])
% set(b(3), 'FaceColor', [0 0 0])
% xlabel('Power','FontSize',18)
% ylabel('Total thoughput','FontSize',18)
% legend('Single', 'Eavesdropping', 'CACA', 'Location','Best')
% set(gca, 'LineWidth', 1.5, 'box', 'on', 'fontsize', 18);

% figure2 : noise 50% 확률로 발생시 total thoughput
% x = cell2mat(s.Range('B15:B22').Value);
% y = cell2mat(s.Range('C15:E22').Value);
% b = bar(x,y);
% xlim([4 22]);
% ylim([0 1500]);
% set(figure(1), 'Position', [200 200 600 400],'Color',[1 1 1])
% set(b(1), 'FaceColor', [0.8, 0.8, 0.8])
% set(b(2), 'FaceColor', [0.4, 0.4, 0.4])
% set(b(3), 'FaceColor', [0 0 0])
% xlabel('Power','FontSize',18)
% ylabel('Total thoughput','FontSize',18)
% legend('Single', 'Eavesdropping', 'CACA', 'Location','Best')
% set(gca, 'LineWidth', 1.5, 'box', 'on', 'fontsize', 18);

% figure3 : power 6, noise 100% 확률로 발생시 각 node별 수신확률 CDF
% x = cell2mat(s.Range('C26:C87').Value);
% h1 = cdfplot(x);
% hold on
% x = cell2mat(s.Range('D26:D87').Value);
% h2 = cdfplot(x);
% hold on
% x = cell2mat(s.Range('E26:E87').Value);
% h3 = cdfplot(x);
% xlim([0 1]);
% ylim([0 1]);
% set(figure(1), 'Position', [200 200 600 400],'Color',[1 1 1])
% xlabel('Trasmission probability (%)','FontSize',18)
% ylabel('CDF','FontSize',18)
% title('');
% legend('Single', 'Eavesdropping', 'CACA', 'Location','Best')
% set(gca, 'LineWidth', 1.5, 'box', 'on', 'fontsize', 18);
% set(h1, 'color', 'black', 'LineWidth',3,'LineStyle','-.', 'LineSmoothing','on');
% set(h2, 'color', 'black', 'LineWidth',4,'LineStyle',':', 'LineSmoothing','on');
% set(h3, 'color', 'black', 'LineWidth',3,'LineStyle','-', 'LineSmoothing','on');

% figure4 : power 6, noise 100% 확률로 발생시 각 node별 수신확률 PDF
% x = cell2mat(s.Range('C26:C87').Value');
% pdfplot(x,20);
% x = cell2mat(s.Range('D26:D87').Value');
% pdfplot(x,20);
% x = cell2mat(s.Range('E26:E87').Value');
% pdfplot(x,20);

% figure5 : power 6, noise 100% 확률로 발생시 각 node별 수신확률 CDF
% x = cell2mat(s.Range('C91:C152').Value);
% h1 = cdfplot(x);
% hold on
% x = cell2mat(s.Range('D91:D152').Value);
% h2 = cdfplot(x);
% hold on
% x = cell2mat(s.Range('E91:E152').Value);
% h3 = cdfplot(x);
% xlim([0 1]);
% ylim([0 1]);
% set(figure(1), 'Position', [200 200 600 400],'Color',[1 1 1])
% xlabel('Trasmission probability (%)','FontSize',18)
% ylabel('CDF','FontSize',18)
% title('');
% legend('Single', 'Eavesdropping', 'CACA', 'Location','Best')
% set(gca, 'LineWidth', 1.7, 'box', 'on', 'fontsize', 18);
% set(h1, 'color', 'black', 'LineWidth',3,'LineStyle','-.', 'LineSmoothing','on');
% set(h2, 'color', 'black', 'LineWidth',4,'LineStyle',':', 'LineSmoothing','on');
% set(h3, 'color', 'black', 'LineWidth',3,'LineStyle','-', 'LineSmoothing','on');

% figure6 : power 6, noise 100% 확률로 발생시 각 node별 수신확률 PDF
% x = cell2mat(s.Range('C91:C152').Value');
% pdfplot(x,20);
% x = cell2mat(s.Range('D91:D152').Value');
% pdfplot(x,20);
% x = cell2mat(s.Range('E91:E152').Value');
% pdfplot(x,20);

% figure7 : power 6, link quality PDF
% x = cell2mat(s.Range('B156:B165').Value');
% y = cell2mat(s.Range('D156:D165').Value');
% bar(x,y, 'k');
% xlim([0 110]);
% ylim([0 0.35]);
% set(figure(1), 'Position', [200 200 600 400],'Color',[1 1 1])
% xlabel('Link quality (%)','FontSize',18)
% ylabel('PDF','FontSize',18)
% set(gca, 'LineWidth', 1.5, 'box', 'on', 'fontsize', 18);

% figure8 : power 6, capture probability PDF
% x = cell2mat(s.Range('B169:B178').Value');
% y = cell2mat(s.Range('D169:D178').Value');
% bar(x,y, 'k');
% xlim([0 110]);
% ylim([0 0.3]);
% set(figure(1), 'Position', [200 200 600 400],'Color',[1 1 1])
% xlabel('Capture probability (%)','FontSize',18)
% ylabel('PDF','FontSize',18)
% set(gca, 'LineWidth', 1.5, 'box', 'on', 'fontsize', 18);

grid on;

delete(excelObj); 
clear;

