function AutoMarker(self)
% Automatically create markers

    % Mark none-zero parts of waveform
    self.marker1 = double(self.waveform1 ~= 0);
    self.marker2 = double(self.waveform2 ~= 0);
end

