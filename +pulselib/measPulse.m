classdef measPulse < handle
    % Simple rectangular measurement pulse object.  
    properties
        name = 'Meas';
        duration = 4e-6; % pulse length in seconds
        amplitude = 1.0; % amplitude of main gaussian pulse
        azimuth = 0.0; % angle in IQ plane.  0 corresponds to I, pi/2 to Q
        sigma = 5e-9; % sigma for Gaussian ramp-up
        cutoff = 30e-9;
        buffer = 2e-9;
        unitary = eye(2);
    end

    properties (Dependent, SetAccess = private)
        totalDuration;
    end
    
    methods
        function self = measPulse(varargin)
            nVarargs = length(varargin);
            switch nVarargs
                case 1
                    self.duration = varargin{1};
                case 2
                    self.duration = varargin{1};
                    self.amplitude = varargin{2};
                case 3
                    self.duration = varargin{1};
                    self.amplitude = varargin{2};
                    self.azimuth = varargin{3};
                case 4
                    self.duration = varargin{1};
                    self.amplitude = varargin{2};
                    self.azimuth = varargin{3};
                    self.sigma = varargin{4};
            end
        end

        function value = get.totalDuration(self)
            value = self.duration + self.cutoff + self.buffer;
        end
        
        function r = rect(self, tAxis, tStart)
            tCtr1 = tStart + (self.cutoff + self.buffer)/2;
            tCtr2 = tCtr1 + self.duration;
            r = self.amplitude.*ones(1,length(tAxis));
            r = r.*(tAxis > tCtr1).*(tAxis < tCtr2) ...
                + r.*(tAxis >= tStart).*(tAxis <= tCtr1).*exp(-((tAxis-tCtr1).^2)./(2.*self.sigma.^2)) ...
                + r.*(tAxis >= tCtr2).*(tAxis <= tStart + self.totalDuration).*exp(-((tAxis-tCtr2).^2)./(2.*self.sigma.^2));
        end
        
        function rc = applyCutoff(self, tAxis, tStart, r)
            offset = self.amplitude*exp(-self.cutoff^2/(8*self.sigma^2));
            rc = (r-offset).*(tAxis >= tStart + self.buffer/2) ...
                 .*(tAxis <= tStart + self.totalDuration - self.buffer/2);
            if max(abs(rc)) ~= abs(self.amplitude)
                rc = rc/max(abs(rc))*abs(self.amplitude);
            end
        end
        
        function [iBaseband, qBaseband] = project(self, r)
            % calculate I and Q baseband using phaseAngle
            iBaseband = cos(self.azimuth).*r;
            qBaseband = sin(self.azimuth).*r;
        end
        
        function [iBaseband, qBaseband] = iqSegment(self, tSegment, tStart)
            % Returns baseband signals for a given time segment
            r = self.rect(tSegment, tStart);
            r = self.applyCutoff(tSegment, tStart, r);
            [iBaseband, qBaseband] = project(self, r);
        end
        
        function [iBaseband, qBaseband] = uwWaveforms(self, tAxis, tStart)
            % Given time axis and pulse start time, returns final baseband signals
            iBaseband = zeros(1, length(tAxis));
            qBaseband = iBaseband;
            tGate = self.totalDuration;
            start = find(tAxis>=tStart, 1);
            stop = find(tAxis<=tStart+tGate, 1, 'last');
            [iBaseband(start:stop), qBaseband(start:stop)] ...
                = self.iqSegment(tAxis(start:stop), tAxis(start));
        end
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(~, stateIn)
            stateOut = stateIn;
            stateTilt = 2*acos(abs(stateOut(1)));
            stateAzimuth = angle(stateOut(2))-angle(stateOut(1));
        end
        
        function s = toStruct(self)
            warning('off', 'MATLAB:structOnObject');
            s = struct(self);
            warning('on', 'MATLAB:structOnObject');
        end
        
        function draw(self) % visualize
            % create waveform time axis
            pulseTime = self.totalDuration;
            t = -10e-9:1e-9:pulseTime+10e-9;
            % make rect function
            rect = self.rect(t, 0);
            % make baseband signals
            [iBaseband, qBaseband] = self.uwWaveforms(t, 0);
            % plot
            figure(722);
            plot(t,rect,'k',t,iBaseband,'b',t,qBaseband,'r');
            title('pulselib.measPulse Object');
            legend('Amplitude','I','Q');
        end
    end
end