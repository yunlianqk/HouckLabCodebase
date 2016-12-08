function PlotQubitSweep(self)
    % Plot qubit frequency sweep
    
    figure(10);
    plot(self.qubitFreq/1e9, self.result.AmpInt);
    xlabel('Frequency (GHz)');
    ylabel('Amplitude');
    title(self.experimentName);
end