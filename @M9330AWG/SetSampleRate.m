function SetSampleRate(self, samplerate)
% Set sampling rate
    maxrate = 1.25e9;
    exponent = log2(maxrate/samplerate);
    % Only set new sampling rate if it is 1.25 GHz divided by 2^n
    if (floor(exponent) ~= ceil(exponent)) || exponent < 0 || exponent > 10
        error(['Sampling rate must be ', num2str(maxrate, '%.3e'), ...
               '/2^n Hz, 0<=n<=10']);
    end
    self.instrhandle.DeviceSpecific.Arbitrary.SampleRate = samplerate;
end

