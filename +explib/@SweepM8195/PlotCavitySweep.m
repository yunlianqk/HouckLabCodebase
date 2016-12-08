function PlotCavitySweep(self)
    % Plot cavity frequency sweep
    
    figure(10);
    plot(self.cavityFreq/1e9, self.result.AmpInt);
    xlabel('Frequency (GHz)');
    ylabel('Amplitude');
    title(self.experimentName);
end