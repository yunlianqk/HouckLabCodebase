function SetUp(self)

    global rfgen logen;
    self.measurement = self.pulseCal.measurement();

    if self.cavitybaseband
        if ~isempty(self.cavityFreq)
            rfgen.freq = self.cavityFreq(1);
        else
            rfgen.freq = self.pulseCal.cavityFreq;
        end
        rfgen.power = self.pulseCal.rfPower;
        rfgen.modulation = 1;
        rfgen.pulse = 1;
        rfgen.iq = 0;
        rfgen.alc = 1;
        rfgen.output = 1;
        
        logen.freq = rfgen.freq + self.pulseCal.intFreq;
        logen.power = self.pulseCal.loPower;
        logen.modulation = 0;
        logen.alc = 1;
        logen.output = 1;
        self.pulseCal.cavityAmplitude = 1;
    else
        rfgen.output = 0;
        logen.output = 0;
    end
end