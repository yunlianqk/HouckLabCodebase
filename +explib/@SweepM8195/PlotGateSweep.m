function PlotGateSweep(self)
    % Plot qubit gate sweep
    
    figure(10);
    plot(self.result.AmpInt);
    xlabel('Sequence');
    ylabel('Amplitude');
    title(self.experimentName);
end