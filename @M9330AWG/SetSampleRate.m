function SetSampleRate(self, samplerate)
% Set sampling rate
    maxrate = 1.25e9;
    exponent = log2(maxrate/samplerate);
    % Only set new sampling rate if it is 1.25 GHz divided by 2^n
    if (floor(exponent) ~= ceil(exponent))
        fprintf('Sampling rate must be %.2e/2^n\n', maxrate);
        return;
    end
    self.instrhandle.DeviceSpecific.Arbitrary.SampleRate = samplerate;
    self.samplingrate = samplerate;
end

