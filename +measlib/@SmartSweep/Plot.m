function Plot(self, fignum)
% Plot data
    if nargin == 1
        fignum = 101;
    end

    if isempty(self.result.intRange)
        self.result.intRange = [self.result.colAxis(1), self.result.colAxis(end)];
    end
   
    figure(fignum);
    % Plot raw data
    numRows = size(self.result.Idata, 1);
    subplot(2, 3, 1);
    imagesc(self.result.colAxis/1e-6, 1:numRows, self.result.Idata);
    hold on;
    plot([self.result.intRange(1), self.result.intRange(1)]/1e-6, ...
         [1, numRows], ...
         '--r', 'LineWidth', 2);
    plot([self.result.intRange(2), self.result.intRange(2)]/1e-6, ...
         [1, numRows], ...
         '--r', 'LineWidth', 2);
    hold off;
    title('Raw data I');
    subplot(2, 3, 4);
    imagesc(self.result.colAxis/1e-6, 1:numRows, self.result.Qdata);
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
    subplot(2, 3, 2);
    plot(self.result.rowAxis, self.result.ampI);
    title('Amplitude I');
    axis tight;
    subplot(2, 3, 5);
    plot(self.result.rowAxis, self.result.ampQ);
    title('Amplitude Q');
    axis tight;
    subplot(2, 3, 3);
    plot(self.result.rowAxis, self.result.phaseI);
    axis tight;
    title('Phase I');
    subplot(2, 3, 6);
    plot(self.result.rowAxis, self.result.phaseQ);
    title('Phase Q');
    axis tight;
end