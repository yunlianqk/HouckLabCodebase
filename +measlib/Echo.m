classdef Echo < measlib.QPulseMeas.QPulseMeas
    
    properties
        piPulse;
        pi2Pulse1;
        pi2Pulse2; % pi pulse and pi/2 pulses, pulselib.singleGate objects
    end
    
    methods
        function self = Echo()
            self = self@measlib.QPulseMeas.QPulseMeas();
            self.params = measlib.QLifeTime.Params();
            self.piPulse = pulselib.singleGate('X180');
            self.pi2Pulse1 = pulselib.singleGate('X90');
            self.pi2Pulse2 = pulselib.singleGate('X90');
            self.data.meastype = 'Echo';
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
            % So amplitude = 0.25 is pi/2 pulse, amplitude = 0.5 is pi pulse
            self.piPulse.amplitude = 0.5;
            self.piPulse.dragAmplitude = 0;
            self.piPulse.azimuth = 0;
            self.piPulse.sigma = self.params.driveSigma;
            self.piPulse.buffer = 4e-9;
            self.piPulse.cutoff = 4*self.params.driveSigma;
            
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
                    + self.piPulse.totalDuration ...
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
            % First pi/2 pulse and echo pi pulse has increasing delay
            delay = (0:self.params.numSteps-1)*self.params.tStep;
            % Second pi/2 pulse has increasing azimuth angle to intentionally
            % create Ramsey-like fringes
            theta = linspace(0, 8*2*pi, self.params.numSteps) + pi;
            self.qWaveforms = zeros(self.params.numSteps*2, length(tAxis));
            for index = 1:self.params.numSteps
                % Center of Echo pi pulse
                tEcho = tMeas - self.pi2Pulse2.totalDuration ...
                        - self.piPulse.totalDuration/2 - delay(index)/2;
                % Center of First pi/2 pulse
                tFirst = tMeas - self.pi2Pulse2.totalDuration ...
                          - self.piPulse.totalDuration ...
                          - self.pi2Pulse1.totalDuration/2 - delay(index);
                % Construct drive waveform for qpulsegen
                [IFirst, QFirst] = self.pi2Pulse1.uwWaveforms(tAxis, tFirst);
                [IEcho, QEcho] = self.piPulse.uwWaveforms(tAxis, tEcho);
                self.pi2Pulse2.azimuth = theta(index);
                [ISecond, QSecond] = self.pi2Pulse2.uwWaveforms(tAxis, tSecond);
                % Odd lines are inphase, even lines are quadrature
                self.qWaveforms(2*index-1,:) = IFirst + IEcho + ISecond;
                self.qWaveforms(2*index,:) = QFirst + QEcho + QSecond;
            end
            self.data.dataAxis = delay;
        end
    end
end