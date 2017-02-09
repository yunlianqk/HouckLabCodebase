function Normalize(self)
% Normalize data
    if self.normalization
        ampGnd = self.result.ampI(end-1);
        ampEx = self.result.ampI(end);
        phaseGnd = self.result.phaseI(end-1);
        phaseEx = self.result.phaseI(end);
        self.result.ampI = (self.result.ampI(1:end-2)-ampGnd) ...
                           /(ampEx-ampGnd);
        self.result.phaseI = (self.result.phaseI(1:end-2)-phaseGnd) ...
                             /(phaseEx-phaseGnd);

        ampGnd = self.result.ampQ(end-1);
        ampEx = self.result.ampQ(end);
        phaseGnd = self.result.phaseQ(end-1);
        phaseEx = self.result.phaseQ(end);
        self.result.ampQ = (self.result.ampQ(1:end-2)-ampGnd) ...
                           /(ampEx-ampGnd);
        self.result.phaseQ = (self.result.phaseQ(1:end-2)-phaseGnd) ...
                             /(phaseEx-phaseGnd);
    end
end