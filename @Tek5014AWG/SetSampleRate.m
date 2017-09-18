function SetSampleRate(self, samplerate)
    % Sets the sample rate on the AWG
    fprintf(tek.instrhandle, 'SOURCE1:FREQUENCY %f;', samplerate)
end

