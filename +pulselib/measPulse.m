classdef measPulse < handle
    % Simple rectangular measurement pulse object.  
    properties
        amplitude; % amplitude of main gaussian pulse
        azimuth; % angle in IQ plane.  0 corresponds to I, pi/2 to Q
        duration; % pulse length in seconds
        sigma; % sigma for Gaussian ramp-up
    end

    properties (Dependent, SetAccess = private)
        totalDuration;
    end
    
    methods
        function self = measPulse(duration)
            if nargin == 0
                duration = 4e-6;
            end
            self.azimuth = 0.0;
            self.amplitude = 1.0;
            self.duration = duration;
            self.sigma = 5e-9;
        end

        function value = get.totalDuration(self)
            value = self.duration + 8*self.sigma;
        end
        
        function r = rect(obj, tAxis, tStart)
            tCtr1 = tStart + 4*obj.sigma;
            tCtr2 = tStart + 4*obj.sigma + obj.duration;
            r = obj.amplitude.*ones(1,length(tAxis));
            r = r.*(tAxis > tCtr1).*(tAxis < tCtr2) ...
                + r.*(tAxis >= tStart).*(tAxis <= tCtr1).*exp(-((tAxis-tCtr1).^2)./(2.*obj.sigma.^2)) ...
                + r.*(tAxis >= tCtr2).*(tAxis <= tCtr2 + 4*obj.sigma).*exp(-((tAxis-tCtr2).^2)./(2.*obj.sigma.^2));
        end
        
        function [iBaseband, qBaseband] = project(self, r)
            % calculate I and Q baseband using phaseAngle
            iBaseband = cos(self.azimuth).*r;
            qBaseband = sin(self.azimuth).*r;
        end
   
        function [iBaseband, qBaseband] = uwWaveforms(self, tAxis, tStart)
            % returns final baseband signals. 
            r = self.rect(tAxis, tStart);
            [iBaseband, qBaseband] = project(self,r);
        end
        
        function s = toStruct(self)
            warning('off', 'MATLAB:structOnObject');
            s = struct(self);
            warning('on', 'MATLAB:structOnObject');
        end
        
        function draw(self) % visualize
            % print some text
%             fprintf(['azimuth: ' num2str(obj.azimuth) '\n'])
%             fprintf(['Total pulse duration (including buffer) ' num2str(obj.totalPulseDuration) 's\n'])
            % create waveform time axis
            pulseTime = self.duration;
            t = linspace(-pulseTime/2, 1.5*pulseTime ,2001); % make time axis twice as long as pulse 
            % make rect function
            rect = self.rect(t,0);
            % make baseband signals
            [iBaseband, qBaseband] = self.uwWaveforms(t, 0);
            % plot
            figure(722);
%             subplot(3,2,1);
            plot(t,rect,'k',t,iBaseband,'b',t,qBaseband,'r');
            title('pulselib.measPulse Object');
            legend('Amplitude','I','Q');
        end
    end
end