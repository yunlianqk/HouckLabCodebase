function Integrate(self)
% Integrate rawdata
    if isempty(self.result.intRange)
        self.result.intRange = [self.result.colAxis(1), self.result.colAxis(end)];
    end
    sub = find(self.result.colAxis >= self.result.intRange(1), 1) ...
          :find(self.result.colAxis <= self.result.intRange(2), 1, 'last');
    self.result.intRange = [self.result.colAxis(sub(1)), self.result.colAxis(sub(end))];
    if isempty(self.result.sampleinterval)
        self.result.sampleinterval = self.result.colAxis(2) - self.result.colAxis(1);
    end
    if (self.result.intFreq == 0)
    % Homodyne
        meanI = mean(self.result.Idata(:, sub), 2)';
        meanQ = mean(self.result.Qdata(:, sub), 2)';
        % Amplitude
        self.result.ampI = sqrt(meanI.^2 +meanQ.^2);
        self.result.ampQ = self.result.ampI;
        % Phase
        self.result.phaseI = atan2(meanQ, meanI);
        self.result.phaseQ = self.result.phaseI;
    else
        % Software heterodyne demodulation
        [self.result.ampI, self.result.phaseI] ...
            = funclib.Demodulate(self.result.sampleinterval, ...
                                 self.result.Idata(:, sub), ...
                                 self.result.intFreq);
        [self.result.ampQ, self.result.phaseQ] ...
            = funclib.Demodulate(self.result.sampleinterval, ...
                                 self.result.Qdata(:, sub), ...
                                 self.result.intFreq);
    end

end