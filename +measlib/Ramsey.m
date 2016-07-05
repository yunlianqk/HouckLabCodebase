classdef Ramsey < measlib.QPulseMeas.QPulseMeas
    
    properties
        pi2Pulse1;
        pi2Pulse2; % pi/2 pulses, pulselib.singleGate objects
    end
    
    methods
        function self = Ramsey()
            self = self@measlib.QPulseMeas.QPulseMeas();
            self.params = measlib.QLifeTime.Params();
            self.pi2Pulse1 = pulselib.singleGate('X90');
            self.pi2Pulse2 = pulselib.singleGate('X90');
            self.data.meastype = 'Ramsey';
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
            % So amplitude = 0.25 is pi/2 pulse
            self.pi2Pulse1.amplitude = 0.25;
            self.pi2Pulse1.dragAmplitude = 0;
            self.pi2Pulse1.azimuth = 0;
            self.pi2Pulse1.sigma = self.params.driveSigma;
            self.pi2Pulse1.buffer = 4e-9;
            self.pi2Pulse1.cutoff = 4*self.params.driveSigma;
            
            self.pi2Pulse2.amplitude = 0.25;
            self.pi2Pulse2.dragAmplitude = 0;
            self.pi2Pulse2.azimuth = 0;
            self.pi2Pulse2.sigma = self.params.driveSigma;
            self.pi2Pulse2.buffer = 4e-9;
            self.pi2Pulse2.cutoff = 4*self.params.driveSigma;
            % Start time of the measurement pulse
            tMeas = self.pi2Pulse1.totalDuration + self.pi2Pulse2.totalDuration ...
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
            % Second pi/2 pulse is right before measurement pulse
            tSecond = tMeas - self.pi2Pulse2.totalDuration/2;
            [ISecond, QSecond] = self.pi2Pulse2.uwWaveforms(tAxis, tSecond);
            % First pi/2 pulse has increasing delay
            delay = (0:self.params.numSteps-1)*self.params.tStep;
            self.qWaveforms = zeros(self.params.numSteps*2, length(tAxis));
            for index = 1:self.params.numSteps
                % Center of first pi/2 pulse
                tFirst = tMeas - self.pi2Pulse2.totalDuration ...
                         - self.pi2Pulse1.totalDuration/2 - delay(index);
                [IFirst, QFirst] = self.pi2Pulse1.uwWaveforms(tAxis, tFirst);
                % Odd lines are inphase, even lines are quadrature
                self.qWaveforms(2*index-1,:) = IFirst + ISecond;
                self.qWaveforms(2*index,:) = QFirst + QSecond;
            end
            self.data.dataAxis = delay;
        end
    end
end