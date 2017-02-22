function Normalize(self)
% Normalize data
    if self.normalization
        ampGnd = self.result.ampInt(end-1);
        ampEx = self.result.ampInt(end);
        phaseGnd = self.result.phaseInt(end-1);
        phaseEx = self.result.phaseInt(end);
        self.result.ampInt = (self.result.ampInt(1:end-2)-ampGnd) ...
                           /(ampEx-ampGnd);
        self.result.phaseInt = (self.result.phaseInt(1:end-2)-phaseGnd) ...
                             /(phaseEx-phaseGnd);

    end
end