function Run(self)
    
    % Generate filename for saving data
    self.savefile = [self.name, '_', datestr(now(), 'yyyymmddHHMMSS'), '.mat'];
    
    for row = 1:self.numSweep1
        for idx1 = 1:length(self.sweep1data)
            feval(self.sweep1func{idx1}, self.sweep1data{idx1}(row));
        end
        for col = 1:self.numSweep2
            for idx2 = 1:length(self.sweep2data)
                feval(self.sweep2func{idx2}, self.sweep2data{idx2}(:, col));
            end
            for idx3 = 1:length(self.sweep3data)
                feval(self.sweep3func{idx3}, self.sweep3data{idx3}(row, col));
            end
            pause(self.waittime);
            [self.result.Idata(col, :), self.result.Qdata(col, :)] ...
                = self.acqsigfunc();
            [bgI, bgQ] = self.acqbgfunc();
            self.result.Idata(col, :) = self.result.Idata(col, :) - bgI;
            self.result.Qdata(col, :) = self.result.Qdata(col, :) - bgQ;
            if mod(col-1, self.plotupdate) == 0
                self.plot2func(self.result.Idata(1:col, :), ...
                               self.result.Qdata(1:col, :));
            end
        end
        self.plot2func(self.result.Idata, self.result.Qdata);
        self.Integrate();
        self.plot1func(self.result.ampI(1:row, :), self.result.phaseI(1:row, :), ...
                       self.result.ampQ(1:row, :), self.result.phaseQ(1:row, :));
    end
    self.plot1func(self.result.ampI, self.result.phaseI, self.result.ampQ, self.result.phaseQ);
    self.Normalize();
end