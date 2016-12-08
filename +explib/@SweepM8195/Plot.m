function Plot(self)
    % Plot results
    
    if ~isempty(self.cavityFreq)
        self.PlotCavitySweep();
    elseif ~isempty(self.qubitFreq)
        self.PlotQubitSweep();
    elseif self.histogram
        self.PlotHistogram();
    else
        self.PlotGateSweep();
    end
end