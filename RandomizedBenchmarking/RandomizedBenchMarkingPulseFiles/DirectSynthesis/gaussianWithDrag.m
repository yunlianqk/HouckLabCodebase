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
        
        function draw(obj) % visualize - draw waveform and bloch vector
            % print some text
            fprintf(['Gate name: ' obj.name '\n'])
            fprintf(['azimuth: ' num2str(obj.azimuth) '\n'])
            fprintf(['rotation: ' num2str(obj.rotation) '\n'])
            fprintf(['unitary rotation matrix:\n'])
            disp(obj.unitary)
            % create waveform time axis
            pulseTime = obj.cutoff+obj.buffer; % calculate length of pulse
            t = linspace(-pulseTime,pulseTime,1001); % make time axis twice as long as pulse 
            % create gaussian
            gaussian = obj.amplitude.*exp(-(t.^2)./(2.*obj.sigma.^2));
            gaussianCutoff = gaussian.*(t>(-obj.cutoff/2)).*(t<(obj.cutoff/2));
            % create drag
            drag = (t./(obj.sigma.^2)).*exp(-(t.^2)./(2.*obj.sigma.^2));
            drag = drag/max(drag); % normalize
            drag = obj.dragAmplitude*drag;
            dragCutoff = drag.*(t>(-obj.cutoff/2)).*(t<(obj.cutoff/2));
            % find I and Q baseband using azimuth
            iBaseband=cos(obj.azimuth).*gaussianCutoff+sin(obj.azimuth).*dragCutoff;
            qBaseband=sin(obj.azimuth).*gaussianCutoff+cos(obj.azimuth).*dragCutoff;
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
%             scatter3(iBaseband, qBaseband,t,'k.');
            scatter3(iBaseband, qBaseband,t,[],1:length(t),'.');
            axis square;
            plotMax=max([max(abs(iBaseband)) max(abs(qBaseband))]);tmax=max(t);
            axis([-plotMax plotMax -plotMax plotMax -tmax tmax])
            title(obj.name),xlabel('I'),ylabel('Q')
            ax=subplot(3,2,6);
            blochSpherePlot(ax,pi,obj.azimuth);
            blochSpherePlot(ax,pi-obj.rotation,obj.azimuth,'replot');
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