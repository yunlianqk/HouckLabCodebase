function [intI, intQ] = Integrate(self, ind)
% Integrate rawdata
    if nargin == 1
        ind = self.numSweep1;
    end
    % Find subrange of data according to self.intrange
    self.result.intRange = self.intrange;
    if isempty(self.result.intRange)
        self.result.intRange = [self.result.tAxis(1), self.result.tAxis(end)];
    end
    sub = find(self.result.tAxis >= self.result.intRange(1), 1) ...
          :find(self.result.tAxis <= self.result.intRange(2), 1, 'last');
    self.result.intRange = [self.result.tAxis(sub(1)), self.result.tAxis(sub(end))];
    % Set sample interval
    if isempty(self.result.sampleinterval)
        self.result.sampleinterval = self.result.tAxis(2) - self.result.tAxis(1);
    end
    % If single channel acquisition, copy data to the other channel
    if length(self.cardchannel) == 1
        switch self.cardchannel{:}
            case 'dataI'
                self.result.dataQ = self.result.dataI;
            case 'dataQ'
                self.result.dataI = self.result.dataQ;
            otherwise
        end
    end
    % Demodulate and integrate data
    if self.result.intFreq == 0
    % Homodyne
        intI = mean(self.result.dataI(:, sub), 2)';
        intQ = mean(self.result.dataQ(:, sub), 2)';
    else
    % Heterodyne
        if length(self.cardchannel) == 1
        % If cardchannel = 'dataIQ' or 'dataI' or 'dataQ'
            [intI, intQ] = funclib.Demodulate(self.result.sampleinterval, ...
                                              self.result.dataI(:, sub), ...
                                              self.result.intFreq);
        else
        % If cardchannel = {'dataI', 'dataQ'}
            [intI, intQ] = funclib.Demodulate(self.result.sampleinterval, ...
                                              self.result.dataI(:, sub), ...
                                              self.result.intFreq);
            [intI2, intQ2] = funclib.Demodulate(self.result.sampleinterval, ...
                                              self.result.dataQ(:, sub), ...
                                              self.result.intFreq);
            self.result.intI2(ind, :) = intI2;
            self.result.intQ2(ind, :) = intQ2;
        end
    end
    % For non-histogram measurement, store integrated data in self.result
    if ~self.histogram
        self.result.intI(ind, :) = intI;
        self.result.intQ(ind, :) = intQ;
    end
end