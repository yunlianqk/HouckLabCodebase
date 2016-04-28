classdef measurementPulse < handle
    % Simple rectangular measurement pulse object.  
    properties
        phaseAngle; % angle in IQ plane.  0 corresponds to I, pi/2 to Q
        amplitude; % amplitude of main gaussian pulse
        duration; % pulse length in seconds
    end
    
    methods
        function obj = measurementPulse()   
            obj.phaseAngle = 0.0;
            obj.amplitude = 1.0;
            obj.duration = 4e-6;
        end
        
        function r = rect(obj, tAxis, tStart)
            r = obj.amplitude.*ones(1,length(tAxis));
            r = r.*(tAxis>(tStart)).*(tAxis<(tStart+obj.duration));
        end
        
        function [iBaseband qBaseband] = project(obj, r)
            % calculate I and Q baseband using phaseAngle
            iBaseband=cos(obj.phaseAngle).*r;
            qBaseband=sin(obj.phaseAngle).*r;
        end
   
        function [iBaseband qBaseband] = uwWaveforms(obj,tAxis, tStart)
            % returns final baseband signals. 
            r = obj.rect(tAxis,tStart);
            [iBaseband qBaseband] = project(obj,r);
        end
        
        function draw(obj) % visualize
            % print some text
%             fprintf(['azimuth: ' num2str(obj.azimuth) '\n'])
%             fprintf(['Total pulse duration (including buffer) ' num2str(obj.totalPulseDuration) 's\n'])
            % create waveform time axis
            pulseTime = obj.duration;
            t = linspace(-pulseTime/2,1.5*pulseTime,2001); % make time axis twice as long as pulse 
            % make rect function
            rect=obj.rect(t,0);
            % make baseband signals
            [iBaseband qBaseband] = obj.uwWaveforms(t, 0);
            % plot
            figure(722);
%             subplot(3,2,1);
            plot(t,rect,'k',t,iBaseband,'b',t,qBaseband,'r');
            title('rectMeasurementPulse Object')
            legend('Amplitude','I','Q')
        end
    end
end