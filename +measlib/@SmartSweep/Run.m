function Run(self)
   
    % Generate filename for saving data
    if ~ismember(self.name, {'OneQubitRB', 'SimRB', 'TwoQubitRB'})
        self.savefile = [self.name, '_', datestr(now(), 'yyyymmddHHMMSS'), '.mat'];
    end

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
            self.acqsigfunc(col);
            [bgI, bgQ] = self.acqbgfunc();
            self.result.dataI(col, :) = self.result.dataI(col, :) - bgI;
            self.result.dataQ(col, :) = self.result.dataQ(col, :) - bgQ;
            if mod(col-1, self.plotupdate) == 0
                self.plot2func(col);
            end
        end
        self.plot2func(col);
        if length(self.cardchannel) == 1
            switch self.cardchannel{:}
                case 'dataI'
                    self.result.dataQ = self.result.dataI;
                case 'dataQ'
                    self.result.dataI = self.result.dataQ;
                otherwise
            end
        end
        self.Integrate(row);
        self.Normalize();
        self.plot1func(row);
    end
    if self.autosave
        self.Save();
    end
end