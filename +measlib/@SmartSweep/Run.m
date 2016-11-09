function Run(self)
    
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
            [self.IQdata.rawdataI(col, :), self.IQdata.rawdataQ(col, :)] ...
                = self.acqsigfunc();
            [bgI, bgQ] = self.acqbgfunc();
            self.IQdata.rawdataI(col, :) = self.IQdata.rawdataI(col, :) - bgI;
            self.IQdata.rawdataQ(col, :) = self.IQdata.rawdataQ(col, :) - bgQ;
            if mod(col-1, self.plotupdateinterval) == 0
                self.plot2func(self.IQdata.rawdataI(1:col, :), ...
                               self.IQdata.rawdataQ(1:col, :));
            end
        end
        self.plot2func(self.IQdata.rawdataI, self.IQdata.rawdataQ);
        self.IQdata = self.IQdata.integrate();
        self.ampI(row, :) = self.IQdata.ampI;
        self.phaseI(row, :) = self.IQdata.phaseI;
        self.ampQ(row, :) = self.IQdata.ampQ;
        self.phaseQ(row, :) = self.IQdata.phaseQ;
        self.plot1func(self.ampI(1:row, :), self.phaseI(1:row, :), ...
                       self.ampQ(1:row, :), self.phaseQ(1:row, :));
    end
    self.plot1func(self.ampI, self.phaseI, self.ampQ, self.phaseQ);
end