function Run(self)
    
    % Generate filename for saving data
    self.savefile = [self.name, '_', datestr(now(), 'yyyymmddHHMMSS'), '.mat'];

    % Run sweep
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
            [self.result.dataI(col, :), self.result.dataQ(col, :)] ...
                = self.acqsigfunc();
            [bgI, bgQ] = self.acqbgfunc();
            self.result.dataI(col, :) = self.result.dataI(col, :) - bgI;
            self.result.dataQ(col, :) = self.result.dataQ(col, :) - bgQ;
            if mod(col-1, self.plotupdate) == 0
                self.plot2func(self.result.dataI(1:col, :), ...
                               self.result.dataQ(1:col, :));
            end
        end
        self.plot2func(self.result.dataI, self.result.dataQ);
        self.Integrate();
        self.plot1func(self.result.ampInt(1:row, :), self.result.phaseInt(1:row, :));
    end

    self.plot1func(self.result.ampInt, self.result.phaseInt);
    self.Normalize();
    if self.autosave
        self.Save();
    end
end