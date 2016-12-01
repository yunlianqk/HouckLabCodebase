function Plot(self)

    if self.cavitybaseband && ~isempty(self.cavityFreq)
        self.PlotCavitySweep();
    elseif self.histogram
        self.PlotHistogram();
    else
        self.PlotGateSweep();
    end
end