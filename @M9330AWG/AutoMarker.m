function AutoMarker(self)
% Deprecated. Set self.mkrauto = 1 instead.
    warning('''AutoMarker'' method is deprecated. Set ''mkrauto'' property to 1 instead.');
    % Mark none-zero parts of waveform
    self.marker2 = double(self.waveform1 ~= 0);
    self.marker4 = double(self.waveform2 ~= 0);
    if length(self.marker1) ~= length(self.marker2)
        self.marker1 = zeros(1, length(self.waveform1));
    end
    if length(self.marker3) ~= length(self.marker2)
        self.marker3 = zeros(1, length(self.waveform1));
    end
end

