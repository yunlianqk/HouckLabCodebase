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
    % Plot raw data
    numRows = size(self.result.dataI, 1);
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
    self.Normalize();
    subplot(2, 2, 2);
    plot(1:numRows, self.result.ampInt);
    title('Amplitude');
    axis tight;
    subplot(2, 2, 4);
    plot(1:numRows, self.result.phaseInt);
    title('Phase');
    axis tight;
end