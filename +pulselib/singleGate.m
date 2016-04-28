classdef singleGate < handle
    % Gate object.  Clifford gates are formed from a few of these primitives
    % together.  This is a basic gaussian pulse with a drag pulse in
    % quadrature. A DC offset is also removed so that @ cutoff voltage is zero. 
    
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
        function obj = singleGate(name)   
            % constructor takes in axis for the pulse. 0 is x pulse (I quadrature), pi/2 is
            % y pulse (Q quadrature) and a rotation angle.  These are used for calculations,
            % but amplitude and dragAmplitude are what actually determine
            % the gate.  These need to be calibrated.
            
            % Default values
            obj.name = name;
            obj.sigma = 10e-9;
            obj.cutoff = 4*obj.sigma;
            obj.buffer = 4e-9;
            obj.dragAmplitude = 0.0;
            % split the name into string and number
            name = regexp(name, '^([a-zA-Z]*)([0-9\.+-]*)', 'tokens', 'once');
            ax = name{1};
            rotation = str2double(name{2});
            
            % If gate is identity of custom
            if ismember(ax, {'Identity', 'Custom'})
                obj.amplitude = 0.0;
                obj.rotation = 0.0;
                obj.azimuth = 0.0;
            else 
            % If gate is X/Y/Z + angle
            % Convention: rotation is always positive
            % azimuth  = 0, pi, pi/2, -pi/2 for X, Xm, Y, Ym
                switch ax
                    case 'X'
                        obj.azimuth = 0;
                    case 'Xm'
                        obj.azimuth = pi;
                    case 'Y'
                        obj.azimuth = pi/2;
                    case 'Ym'
                        obj.azimuth = -pi/2;
                    otherwise
                        error(['Undefined gate: Gate names should be ', ...
                               '''Identity'', ''Custom'', ''X180'', ''Ym90'', etc.']);
                end
                if ~isnan(rotation)
                    obj.amplitude = rotation/180;
                    obj.rotation = rotation/180*pi;
                else
                    error('Rotation angle should be a number');
                end
            end
          
            % calculate gate unitary
            sm =[0 1; 0 0];
            sp = sm';
            sx = full(sp+sm);
            sy = full(1i*sp-1i*sm);
%             sz = [1 0;0 -1];
            unitary = expm(-1i*obj.rotation/2*(cos(obj.azimuth)*sx + ...
                                               sin(obj.azimuth)*sy));
            obj.unitary = unitary;
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
        
        function wc = applyGaussianCutoff(obj, tAxis, tCenter, w)
            % zeros out values of waveform outside of cutoff and removes
            % offset
            firstPoint=find((tAxis>(tCenter-obj.cutoff/2)),1);            
            offset=w(firstPoint);            
            wc = (w-offset).*(tAxis>(tCenter-obj.cutoff/2)).*(tAxis<(tCenter+obj.cutoff/2));
        end
        
        function wc = applyDragCutoff(obj, tAxis, tCenter, w)
            % zeros out values of waveform outside of cutoff and removes
            % offset
%             firstPoint=find((tAxis>(tCenter-obj.cutoff/2)),1);            
%             offset=w(firstPoint);            
            offset=0;
            wc = (w-offset).*(tAxis>(tCenter-obj.cutoff/2)).*(tAxis<(tCenter+obj.cutoff/2));
        end
        
        function [iBaseband, qBaseband] = project(obj,g, d)
            % find I and Q baseband using azimuth - g is main gaussian
            % waveform and d is drag waveform
            iBaseband=cos(obj.azimuth).*g+sin(obj.azimuth).*d;
            qBaseband=sin(obj.azimuth).*g+cos(obj.azimuth).*d;
        end
        
        function [iBaseband, qBaseband] = uwWaveforms(obj,tAxis, tCenter)
            % given just a time axis and pulse time, returns final baseband
            % signals. can be added to similar outputs from other gates to
            % form a composite waveform
            g = obj.gaussian(tAxis,tCenter);
            d = obj.drag(tAxis,tCenter);
            gc = obj.applyGaussianCutoff(tAxis,tCenter, g);
            dc = obj.applyDragCutoff(tAxis,tCenter, d);
            [iBaseband, qBaseband] = project(obj,gc, dc);
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
            gaussianCutoff = obj.applyGaussianCutoff(t, 0, gaussian);
            % create drag
            drag = obj.drag(t, 0);
            dragCutoff = obj.applyDragCutoff(t, 0, drag);
            % find I and Q baseband using azimuth
            [iBaseband, qBaseband] = project(obj,gaussianCutoff, dragCutoff);
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
            plotlib.blochSpherePlot(ax,0,0);
            [stateOut, stateTilt, stateAzimuth] = obj.actOnState([1;0]);
            plotlib.blochSpherePlot(ax,stateTilt,stateAzimuth,'replot');
            subplot(3,2,5);
            plot(t,iBaseband,'b',t,qBaseband,'r')
            title('I and Q baseband waveforms')
            legend('I','Q')
        end
    end
end