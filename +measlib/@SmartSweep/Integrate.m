function [intI, intQ] = Integrate(self, ind)
% Integrate rawdata
    if nargin == 1
        ind = self.numSweep1;
    end
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
        intI = mean(self.result.dataI(:, sub), 2)';
        intQ = mean(self.result.dataQ(:, sub), 2)';
    else
        % Software heterodyne demodulation
        [intI, intQ] = funclib.Demodulate(self.result.sampleinterval, ...
                                          self.result.dataI(:, sub), ...
                                          self.result.intFreq);
    end
    % For non-histogram measurement, store integrated data in self.result
    if ~self.histogram
        self.result.intI(ind, :) = intI;
        self.result.intQ(ind, :) = intQ;
    end
end