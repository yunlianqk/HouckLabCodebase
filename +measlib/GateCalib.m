classdef GateCalib < measlib.QPulseMeas.QPulseMeas
    
    properties
        qPulse; % An array of pulselib.singleGate objects
    end
    
    methods
        function self = GateCalib()
            self = self@measlib.QPulseMeas.QPulseMeas();
            self.data.meastype = 'GateCalib';
        end
    end
    methods (Access = protected)
        function setWaveforms(self)
        % Set the waveforms for AWG
            % Set mPulse
            self.mPulse.duration = self.params.measDuration;
            % Start time of the measurement pulse
            tMeas = max(size(self.qPulse, 2)*self.qPulse(1,1).totalDuration, 5e-6);
            % Total duration of each measurement
            tTotal = tMeas + self.mPulse.totalDuration + 0.5e-6;
            dt = 1/self.instr.mpulsegen.samplingrate;
            % Time axis for AWG
            tAxis = 0:dt:tTotal;
            self.instr.mpulsegen.timeaxis = tAxis;
            self.instr.qpulsegen.timeaxis = tAxis;
            % Create waveforms for mpulsegen
            % This amplitude is calibrated for vector generator E8267D
            self.mPulse.amplitude = 0.26;
            [self.instr.mpulsegen.waveform1, self.instr.mpulsegen.waveform2] ...
                = self.mPulse.uwWaveforms(tAxis, tMeas);
            % Create waveforms for qpulsegen
            % Center of each column of Gaussian pulse
            tCenter = tMeas - ((size(self.qPulse, 2):-1:1) - 0.5) ...
                              *self.qPulse(1,1).totalDuration;
            self.qWaveforms = zeros(size(self.qPulse, 1)*2, length(tAxis));
            for row = 1:size(self.qPulse, 1)
                for col = 1:size(self.qPulse, 2)
                    [iTemp, qTemp] = self.qPulse(row, col).uwWaveforms(tAxis, tCenter(col));
                    self.qWaveforms(2*row-1,:) = self.qWaveforms(2*row-1,:) + iTemp;
                    self.qWaveforms(2*row,:) = self.qWaveforms(2*row,:) + qTemp;
                end
            end
            self.data.dataAxis = 1:size(self.qPulse, 1);
        end
    end
end

