function Integrate(self)
% Integrate rawdata
    self.result.intRange = self.intrange;
    if isempty(self.result.intRange)
        self.result.intRange = [self.result.tAxis(1), self.result.tAxis(end)];
    end
    sub = find(self.result.tAxis >= self.result.intRange(1), 1) ...
          :find(self.result.tAxis <= self.result.intRange(2), 1, 'last');
    self.result.intRange = [self.result.tAxis(sub(1)), self.result.tAxis(sub(end))];
    if isempty(self.result.sampleinterval)
        self.result.sampleinterval = self.result.tAxis(2) - self.result.tAxis(1);
    end
    if (self.result.intFreq == 0)
    % Homodyne
        meanI = mean(self.result.dataI(:, sub), 2)';
        meanQ = mean(self.result.dataQ(:, sub), 2)';
        % Amplitude
        self.result.ampInt = sqrt(meanI.^2 +meanQ.^2);
        % Phase
        self.result.phaseInt = atan2(meanQ, meanI);
    else
        % Software heterodyne demodulation
        [self.result.ampInt, self.result.phaseInt] ...
            = funclib.Demodulate(self.result.sampleinterval, ...
                                 self.result.dataI(:, sub), ...
                                 self.result.intFreq);
    end

end