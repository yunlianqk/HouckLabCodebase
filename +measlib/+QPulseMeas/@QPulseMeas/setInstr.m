function setInstr(self)
% Set up all instrument except qpulsegen

    % Set up generators
    self.instr.specgen.SetFreq(self.params.driveFreq);
    self.instr.specgen.SetPower(self.params.drivePower);
    self.instr.specgen.ModOn();
    self.instr.specgen.PowerOn();
    self.instr.rfgen.SetFreq(self.params.measFreq);
    self.instr.rfgen.SetPower(self.params.measPower);
    self.instr.rfgen.ModOn();
    self.instr.rfgen.PowerOn();
    self.instr.logen.SetFreq(self.params.measFreq+self.params.intFreq);
    self.instr.logen.SetPower(self.params.loPower);
    self.instr.logen.PowerOn();
    self.data.intFreq = self.params.intFreq;
    
    % Set up AWG
    % Make sure mpulsegen and qpulsegen are synchronized
    if ~strcmp(self.instr.mpulsegen.instrhandle.DeviceSpecific.Output.SyncMode, ...
               'AgM933xSyncModeSlave')
        self.instr.mpulsegen.SyncWith(self.instr.qpulsegen);
    end
    % Marker offset is calibrated for vector generator E8267D
    self.instr.qpulsegen.mkr1offset = -64;
    self.instr.qpulsegen.mkr2offset = -64;    
    % Generate measurement pulse
    self.instr.mpulsegen.AutoMarker();
    self.instr.mpulsegen.Generate();
    
    % Set up acqiris digitizer
    card = self.instr.digitizer;
    % Find the start of the measurement pulse
    tMeas = self.instr.mpulsegen.timeaxis(find(self.instr.mpulsegen.waveform1, 1));
    % Total length of the measurement
    tTotal = self.instr.mpulsegen.timeaxis(end)-self.instr.mpulsegen.timeaxis(1);
    card.params.segments = 1;
    card.params.averages = self.params.numAvg;
    card.params.delaytime = tMeas + self.params.cardDelay;
    card.params.samples = round((self.params.measDuration + 1e-6)/card.params.sampleinterval);
    card.params.timeout = max(10, round(self.params.numAvg*self.params.trigPeriod+1));
    
    % Set up trigger generator
    trigMin = max(tTotal, ...
                  card.params.sampleinterval*card.params.samples ...
                  + card.params.delaytime + 2e-6);
    % Make sure trigger period is long enough
    if self.params.trigPeriod < trigMin
        self.params.trigPeriod = ceil((trigMin)/10e-6)*10e-6;
        fprintf('Trigger period too short. Reset to %g micro second.\n', ...
                self.params.trigPeriod/1e-6);
    end
    self.instr.triggen.SetFreq(1/self.params.trigPeriod);
    self.instr.triggen.PowerOn();
end

