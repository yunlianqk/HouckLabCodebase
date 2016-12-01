function PlotGateSweep(self)
    figure(10);
    plot(self.result.AmpInt);
    xlabel('Sequence');
    ylabel('Amplitude');
    title(self.experimentName);
end