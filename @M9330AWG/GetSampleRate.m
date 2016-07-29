function samplerate = GetSampleRate(self)
% Get sampling rate

    samplerate = self.instrhandle.DeviceSpecific.Arbitrary.SampleRate;
end