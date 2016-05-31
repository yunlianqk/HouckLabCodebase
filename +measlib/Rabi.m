classdef Rabi < measlib.QPulseMeas.QPulseMeas

    properties
        piPulse; % pi pulse, a pulselib.singleGate object
    end
    
    methods
        function self = Rabi()
            self = self@measlib.QPulseMeas.QPulseMeas();
            self.params = measlib.QLifeTime.Params();
            self.piPulse = pulselib.singleGate('X180');
            self.data.meastype = 'Rabi';
        end
        
        function result = fitData(self)
        % Fit data
            [self.data.intdataI, self.data.intdataQ] ...
                = measlib.QPulseMeas.integrateData(self.data);
            result = measlib.QLifeTime.fitData(self.data);
        end
    end
    
    methods (Access = protected)    
        function setWaveforms(self)
        % Set the waveforms for AWG
            % Set pulse objects
            self.mPulse.duration = self.params.measDuration;
            self.piPulse.sigma = self.params.driveSigma;
            self.piPulse.dragAmplitude = 0;
            self.piPulse.azimuth = 0;
            self.piPulse.buffer = 4e-9;
            self.piPulse.cutoff = 4*self.params.driveSigma;
            % Start time of the measurement pulse
            tMeas = 5e-6;
            % Center of the Gaussian pulse for qubit drive
            tDrive = tMeas - self.piPulse.totalDuration/2;
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
            % Create waveforms with increasing amplitude for qpulsegen
            rabiamp = linspace(0, 1, self.params.numSteps);
            self.qWaveforms = zeros(self.params.numSteps*2, length(tAxis));
            for step = 1:self.params.numSteps
                % Odd lines are inphase, even lines are quadrature
                self.piPulse.amplitude = rabiamp(step);
                [self.qWaveforms(2*step-1,:), self.qWaveforms(2*step,:)] ...
                    = self.piPulse.uwWaveforms(tAxis, tDrive);
            end
            self.data.dataAxis = rabiamp;
        end
    end
end