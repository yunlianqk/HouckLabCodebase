function PlotHistogram(self)
    figure(10);
    subplot(2, 1, 1);
    plot(self.result.AmpEdges(2:end), self.result.AmpCounts);
    xlabel('Amplitude');
    ylabel('Counts');
    title(self.experimentName);
    legend(cellstr(num2str((1:length(self.playlist))')));
    subplot(2, 1, 2);
    plot(self.result.PhaseEdges(2:end), self.result.PhaseCounts);
    xlabel('Phase');
    ylabel('Counts');
end