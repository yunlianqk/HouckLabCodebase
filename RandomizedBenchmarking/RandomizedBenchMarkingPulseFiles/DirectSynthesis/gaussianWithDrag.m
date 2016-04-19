classdef gaussianWithDrag < handle
    % Gate object.  Clifford gates are formed from a few of these primitives
    % together.  This is a basic gaussian pulse with a drag pulse in
    % quadrature.  
    
    properties
        name;
        unitary; % unitary matrix of ideal gate
        rotation; % pi, pi/2 etc.  amount of rotation in radians
        azimuth; % angle in equator of bloch sphere and IQ plane.  0 corresponds to x rotation, pi/2 to y rotation
        amplitude; % amplitude of main gaussian pulse
        dragAmplitude; % amplitude of drag pulse in quadrature
        sigma; % gaussian width in seconds
        cutoff; % force pulse tail to zero. this is the total time the pulse is nonzero in seconds
        buffer; % extra time beyond the cutoff to separate gates.  this is the total buffer, so half before and half after.
    end
    
    properties (Dependent, SetAccess = private)
        totalPulseDuration;
    end
    
    methods
        function obj=gaussianWithDrag(name, azimuth, rotation, amplitude, dragAmplitude, sigma, cutoff, buffer)   
            % constructor takes in axis for the pulse. 0 is x pulse (I quadrature), pi/2 is
            % y pulse (Q quadrature) and a rotation angle.  These are used for calculations,
            % but amplitude and dragAmplitude are what actually determine
            % the gate.  These need to be calibrated.
            obj.name=name;
            obj.azimuth=azimuth;
            obj.rotation=rotation;
            obj.amplitude=amplitude;
            obj.dragAmplitude=dragAmplitude;
            obj.sigma=sigma;
            obj.cutoff=cutoff;
            obj.buffer=buffer;
            
            % calculate gate unitary
            sm =[0 1; 0 0];
            sp = sm';
            sx = full(sp+sm);
            sy = full(1i*sp-1i*sm);
            sz = [1 0;0 -1];
            unitary=expm(-1i*rotation/2*(cos(azimuth)*sx+sin(azimuth)*sy));
            obj.unitary=unitary;
        end
        
        function value = get.totalPulseDuration(obj)
            value = obj.cutoff+obj.buffer;
        end
        
        function g = gaussian(obj,tAxis, tCenter)
            % given the time for the center of the pulse and a
            % time axis, generates the base gaussian waveform.
            g = obj.amplitude.*exp(-((tAxis-tCenter).^2)./(2.*obj.sigma.^2));
        end
        
        function d = drag(obj,tAxis, tCenter)
            % given the time for the center of the pulse and a
            % time axis, generates the base gaussian waveform.
            d = ((tAxis-tCenter)./(obj.sigma.^2)).*exp(-((tAxis-tCenter).^2)./(2.*obj.sigma.^2));
            d = d/max(d); % normalize
            d = obj.dragAmplitude*d;
        end
        
        function wc = applyCutoff(obj, tAxis, tCenter, w)
            % zeros out values of waveform outside of cutoff
            wc = w.*(tAxis>(tCenter-obj.cutoff/2)).*(tAxis<(tCenter+obj.cutoff/2));
        end
        
        function [iBaseband qBaseband] = project(obj,g, d)
            % find I and Q baseband using azimuth - g is main gaussian
            % waveform and d is drag waveform
            iBaseband=cos(obj.azimuth).*g+sin(obj.azimuth).*d;
            qBaseband=sin(obj.azimuth).*g+cos(obj.azimuth).*d;
        end
        
        function [iBaseband qBaseband] = uwWaveforms(obj,tAxis, tCenter)
            % given just a time axis and pulse time, returns final baseband
            % signals. can be added to similar outputs from other gates to
            % form a composite waveform
            g = obj.gaussian(tAxis,tCenter);
            d = obj.drag(tAxis,tCenter);
            gc = obj.applyCutoff(tAxis,tCenter, g);
            dc = obj.applyCutoff(tAxis,tCenter, d);
            [iBaseband qBaseband] = project(obj,gc, dc);
        end
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(obj,stateIn)
            % given an input state vector act with unitary and return final state 
            stateOut=obj.unitary*stateIn;
            stateTilt = 2*acos(abs(stateOut(1)));
            stateAzimuth = angle(stateOut(2))-angle(stateOut(1));
        end
            
        
        function draw(obj) % visualize - draw waveform and bloch vector
            % print some text
            fprintf(['Gate name: ' obj.name '\n'])
            fprintf(['azimuth: ' num2str(obj.azimuth) '\n'])
            fprintf(['rotation: ' num2str(obj.rotation) '\n'])
            fprintf(['unitary rotation matrix:\n'])
            disp(obj.unitary)
            fprintf(['Total pulse duration (including buffer) ' num2str(obj.totalPulseDuration) 's\n'])
            % create waveform time axis
            pulseTime = obj.totalPulseDuration;
            t = linspace(-pulseTime,pulseTime,1001); % make time axis twice as long as pulse 
            % create gaussian
            gaussian = obj.gaussian(t, 0);
            gaussianCutoff = obj.applyCutoff(t, 0, gaussian);
            % create drag
            drag = obj.drag(t, 0);
            dragCutoff = obj.applyCutoff(t, 0, drag);
            % find I and Q baseband using azimuth
            [iBaseband qBaseband] = project(obj,gaussianCutoff, dragCutoff);
            % buffer
            buffer = (t>-pulseTime/2).*(t<pulseTime/2);
            % plot
            figure(712);
            subplot(3,2,1);
            plot(t,gaussian,'b',t,gaussianCutoff,'r',t,buffer*max(gaussian),'k');
            title('gaussian pulse')
            subplot(3,2,3);
            plot(t,drag,'b',t,dragCutoff,t,buffer*max(drag),'k');
            title('drag pulse')
            subplot(3,2,[2,4]);
            scatter3(iBaseband, qBaseband,t,[],1:length(t),'.');
            axis square;
            plotMax=max([max(abs(iBaseband)) max(abs(qBaseband))]);tmax=max(t);
            if plotMax==0
                plotMax=1;
            end
            axis([-plotMax plotMax -plotMax plotMax -tmax tmax])
            title(obj.name),xlabel('I'),ylabel('Q')
            ax=subplot(3,2,6);
            blochSpherePlot(ax,0,0);
            [stateOut, stateTilt, stateAzimuth] = obj.actOnState([1;0]);
            blochSpherePlot(ax,stateTilt,stateAzimuth,'replot');
            subplot(3,2,5);
            plot(t,iBaseband,'b',t,qBaseband,'r')
            title('I and Q baseband waveforms')
            legend('I','Q')
        end
    end
end
            
        
        

        
% list of the primitives        
% QIdPulse = 'QId';
% XpPulse = 'Xp';
% YpPulse = 'Yp';
% XmPulse = 'Xm';
% YmPulse = 'Ym';
% X90pPulse = 'X90p';
% Y90pPulse = 'Y90p';
% X90mPulse = 'X90m';
% Y90mPulse = 'Y90m';