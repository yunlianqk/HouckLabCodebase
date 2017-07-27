function Plot(self, fignum)
% Plot data
    if nargin == 1
        fignum = 101;
    end

    self.result.intRange = self.intrange;
    if isempty(self.result.intRange)
        self.result.intRange = [self.result.tAxis(1), self.result.tAxis(end)];
    end

    figure(fignum);
    if self.histogram
        histPlot(self);
    else
        % Plot Raw and integrated data
        dataPlot(self);
        % Plot tomography data
        TomoPlot(self,fignum);
    end
    drawnow;
end

function dataPlot(self)
        numRows = size(self.result.dataI, 1);
        % Plot raw data
        subplot(2, 2, 1);
        imagesc(self.result.tAxis/1e-6, 1:numRows, self.result.dataI);
        hold on;
        plot([self.result.intRange(1), self.result.intRange(1)]/1e-6, ...
             [1, numRows], ...
             '--r', 'LineWidth', 2);
        plot([self.result.intRange(2), self.result.intRange(2)]/1e-6, ...
             [1, numRows], ...
             '--r', 'LineWidth', 2);
        hold off;
        title('Raw data I');
        subplot(2, 2, 3);
        imagesc(self.result.tAxis/1e-6, 1:numRows, self.result.dataQ);
        hold on;
        plot([self.result.intRange(1), self.result.intRange(1)]/1e-6, ...
             [1, numRows], ...
             '--r', 'LineWidth', 2);
        plot([self.result.intRange(2), self.result.intRange(2)]/1e-6, ...
             [1, numRows], ...
             '--r', 'LineWidth', 2);
        hold off;
        xlabel('Time (\mus)');
        title('Raw data Q');
        % Plot integrated/demodulated data
        self.Integrate();
        subplot(2, 2, 2);
        plot(1:numRows, self.result.intI);
        title('Integrated I');
        axis tight;
        subplot(2, 2, 4);
        plot(1:numRows, self.result.intQ);
        title('Integrated Q');
        axis tight;


end
function histPlot(self)
        numRows = size(self.result.intI, 1);
        self.result.countsI = zeros(numRows, self.histbins);
        self.result.countsQ = zeros(numRows, self.histbins);
        self.result.edgesI = linspace(min(min(self.result.intI)), ...
                                      max(max(self.result.intI)), ...
                                      self.histbins+1);
        self.result.edgesQ = linspace(min(min(self.result.intQ)), ...
                                      max(max(self.result.intQ)), ...
                                      self.histbins+1);
        for row = 1:numRows
            [self.result.countsI(row, :), ~] ...
                = histcounts(self.result.intI(row, :), self.result.edgesI);
            [self.result.countsQ(row, :), ~] ...
                = histcounts(self.result.intQ(row, :), self.result.edgesQ);
        end
        subplot(2, 1, 1);
        plot(self.result.edgesI(2:end), self.result.countsI);
        xlabel('I data');
        ylabel('Counts');
        legend(cellstr(num2str((1:numRows)')));
        subplot(2, 1, 2);
        plot(self.result.edgesI(2:end), self.result.countsQ);
        xlabel('Q data');
        ylabel('Counts');
end

function TomoPlot(self,fignum)
            % Plot tomography
            figure(fignum+1);
            plot(1:3, self.result.TomoAmp, '-o');
            set(gca, 'xtick', 1:3);
            set(gca, 'xticklabel', {'Id','X90','Y90'});
            set(gca, 'xticklabelrotation', 45);
            axis([0, 3+1, -0.2, 1.2]);
            plotlib.hline(1);
            plotlib.hline(0);
            plotlib.hline(0.5);
            hold on;
            for ind = 1:3
                plot([ind, ind], [-0.2, self.result.TomoAmp(ind)], 'r:');
            end
            hold off;
            title([self.name,'Q1Tomography']);
            ylabel('P(|0>)');
			drawnow;
            if length(self.cardchannel) == 2
                figure(fignum+2);
                plot(1:3, self.result.TomoAmp2, '-o');
                set(gca, 'xtick', 1:3);
                set(gca, 'xticklabel', {'Id','X90','Y90'});
                set(gca, 'xticklabelrotation', 45);
                axis([0, 3+1, -0.2, 1.2]);
                plotlib.hline(1);
                plotlib.hline(0);
                plotlib.hline(0.5);
                hold on;
                for ind = 1:3
                    plot([ind, ind], [-0.2, self.result.TomoAmp2(ind)], 'r:');
                end
                hold off;
                title([self.name,'_Q2Tomography']);
                ylabel('P(|0>)');
                drawnow;
            end
end