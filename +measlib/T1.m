classdef T1 < measlib.QPulseMeas.QPulseMeas
    %T1 Summary of this class goes here

    properties
        piPulse; % pi pulse, a pulselib.singleGate object
    end
    
    methods
        function self = T1()
            self = self@measlib.QPulseMeas.QPulseMeas();
            self.params = measlib.QLifeTime.Params();
            self.piPulse = pulselib.singleGate('X180');
            self.data.meastype = 'T1';
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
            % In Rabi experiment, amplitude = 1.0 gives a 2pi rotation
            % So amplitude = 0.5 is pi pulse
            self.piPulse.sigma = self.params.driveSigma;
            self.piPulse.amplitude = 0.5;
            self.piPulse.dragAmplitude = 0;
            self.piPulse.azimuth = 0;
            self.piPulse.buffer = 4e-9;
            self.piPulse.cutoff = 4*self.params.driveSigma;
            % Start time of the measurement pulse
            tMeas = self.piPulse.totalDuration ...
                    + self.params.tStep*(self.params.numSteps-1) + 0.5e-6;
            % Total duration of each measurement
            tTotal = tMeas + self.mPulse.totalDuration + 0.5e-6;
            % Time axis for AWG
            dt = 1/self.instr.mpulsegen.samplingrate;
            tAxis = 0:dt:tTotal;
            self.instr.mpulsegen.timeaxis = tAxis;
            self.instr.qpulsegen.timeaxis = tAxis;
            % Create waveforms for mpulsegen
            % This amplitude is calibrated for vector generator E8267D
            self.mPulse.amplitude = 0.26;
            [self.instr.mpulsegen.waveform1, self.instr.mpulsegen.waveform2] ...
                = self.mPulse.uwWaveforms(tAxis, tMeas);
            % Create waveforms with increasing delay for qpulsegen
            delay = (0:self.params.numSteps-1)*self.params.tStep;
            self.qWaveforms = zeros(self.params.numSteps*2, length(tAxis));
            for index = 1:self.params.numSteps
                % Start time of each pi pulse
                tDrive = tMeas - self.piPulse.totalDuration/2 - delay(index);
                % Odd lines are inphase, even lines are quadrature
                [self.qWaveforms(2*index-1,:), self.qWaveforms(2*index,:)] ...
                    = self.piPulse.uwWaveforms(tAxis, tDrive);
            end
            self.data.dataAxis = delay;
        end
    end
end