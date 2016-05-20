classdef singleGate < handle
    % Single qubit gate object. 
    % This is a basic gaussian pulse with a drag pulse in quadrature. 
    % A DC offset is also removed so that @ cutoff voltage is zero. 
    
    properties
        name; % can be 'Identity', 'Custom', 'X180', 'Ym90', etc.
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
        totalDuration;
    end
    
    methods
        function self = singleGate(name)   
            % Constructor takes the name of the gate to create an object
            
            % Default values
            if nargin == 0
                name = 'Identity';
            end
            self.name = name;
            self.sigma = 10e-9;
            self.cutoff = 4*self.sigma;
            self.buffer = 4e-9;
            self.dragAmplitude = 0.0;
            % split the name into string and number
            name = regexp(name, '^([a-zA-Z]*)([0-9\.+-]*)', 'tokens', 'once');
            ax = name{1};
            rotation = str2double(name{2});
            
            % If gate is 'Identity' or 'Custom'
            if ismember(ax, {'Identity', 'Custom'})
                self.amplitude = 0.0;
                self.rotation = 0.0;
                self.azimuth = 0.0;
            else 
            % If gate is X/Y rotation
            % Convention: azimuth  = 0, pi, pi/2, -pi/2 for X, Xm, Y, Ym
                switch ax
                    case 'X'
                        self.azimuth = 0;
                    case 'Xm'
                        self.azimuth = pi;
                    case 'Y'
                        self.azimuth = pi/2;
                    case 'Ym'
                        self.azimuth = -pi/2;
                    otherwise
                        error(['Undefined gate: Gate names should be ', ...
                               '''Identity'', ''Custom'', ''X180'', ''Ym90'', etc.']);
                end
            % Set amplitude and rotation
                if ~isnan(rotation)
                    self.amplitude = rotation/180;
                    self.rotation = rotation/180*pi;
                else
                    error('Rotation angle should be a number');
                end
            end
          
            % calculate gate unitary
            sm =[0 1; 0 0];
            sp = sm';
            sx = full(sp+sm);
            sy = full(1i*sp-1i*sm);
            self.unitary = expm(-1i*self.rotation/2 ...
                               *(cos(self.azimuth)*sx + sin(self.azimuth)*sy));
        end
        
        function value = get.totalDuration(obj)
            value = obj.cutoff+obj.buffer;
        end
        
        function g = gaussian(self, tAxis, tCenter)
            % given the time for the center of the pulse and a
            % time axis, generates the base gaussian waveform.
            g = self.amplitude.*exp(-((tAxis-tCenter).^2)./(2.*self.sigma.^2));
        end
        
        function d = drag(self, tAxis, tCenter)
            % given the time for the center of the pulse and a
            % time axis, generates the drag waveform.
            d = ((tAxis-tCenter)./(self.sigma.^2)).*exp(-((tAxis-tCenter).^2)./(2.*self.sigma.^2));
            d = d/max(d); % normalize
            d = self.dragAmplitude*d;
        end
        
        function wc = applyGaussianCutoff(self, tAxis, tCenter, w)
            % zeros out values of waveform outside of cutoff and removes offset
            offset = w(find((tAxis>(tCenter-self.cutoff/2)),1));            
            wc = (w-offset).*(tAxis>(tCenter-self.cutoff/2)).*(tAxis<(tCenter+self.cutoff/2));
            % normalize
            if max(abs(wc)) ~= abs(self.amplitude)
                wc = wc/max(abs(wc))*abs(self.amplitude);
            end
        end
        
        function wc = applyDragCutoff(self, tAxis, tCenter, w)
            % zeros out values of waveform outside of cutoff and removes
            % offset
%             firstPoint=find((tAxis>(tCenter-obj.cutoff/2)),1);            
%             offset=w(firstPoint);            
            offset=0;
            wc = (w-offset).*(tAxis>(tCenter-self.cutoff/2)).*(tAxis<(tCenter+self.cutoff/2));
        end
        
        function [iBaseband, qBaseband] = project(self, g, d)
            % find I and Q baseband using azimuth - g is main gaussian
            % waveform and d is drag waveform
            iBaseband=cos(self.azimuth).*g+sin(self.azimuth).*d;
            qBaseband=sin(self.azimuth).*g+cos(self.azimuth).*d;
        end
        
        function [iBaseband, qBaseband] = uwWaveforms(self, tAxis, tCenter)
            % given just a time axis and pulse time, returns final baseband
            % signals. can be added to similar outputs from other gates to
            % form a composite waveform
            g = self.gaussian(tAxis,tCenter);
            d = self.drag(tAxis,tCenter);
            gc = self.applyGaussianCutoff(tAxis,tCenter, g);
            dc = self.applyDragCutoff(tAxis,tCenter, d);
            [iBaseband, qBaseband] = project(self,gc, dc);
        end
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(self, stateIn)
            % given an input state vector act with unitary and return final state 
            stateOut=self.unitary*stateIn;
            stateTilt = 2*acos(abs(stateOut(1)));
            stateAzimuth = angle(stateOut(2))-angle(stateOut(1));
        end
            
        
        function draw(self) % visualize - draw waveform and bloch vector
            % print some text
            fprintf(['Gate name: ' self.name '\n']);
            fprintf(['azimuth: ' num2str(self.azimuth) '\n']);
            fprintf(['rotation: ' num2str(self.rotation) '\n']);
            fprintf('unitary rotation matrix:\n');
            disp(self.unitary);
            fprintf(['Total pulse duration (including buffer) ' num2str(self.totalDuration) 's\n'])
            % create waveform time axis
            pulseTime = self.totalDuration;
            t = linspace(-pulseTime,pulseTime,1001); % make time axis twice as long as pulse 
            % create gaussian
            gaussian = self.gaussian(t, 0);
            gaussianCutoff = self.applyGaussianCutoff(t, 0, gaussian);
            % create drag
            drag = self.drag(t, 0);
            dragCutoff = self.applyDragCutoff(t, 0, drag);
            % find I and Q baseband using azimuth
            [iBaseband, qBaseband] = project(self,gaussianCutoff, dragCutoff);
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
            title(self.name),xlabel('I'),ylabel('Q')
            ax=subplot(3,2,6);
            plotlib.blochSpherePlot(ax,0,0);
            [stateOut, stateTilt, stateAzimuth] = self.actOnState([1;0]);
            plotlib.blochSpherePlot(ax,stateTilt,stateAzimuth,'replot');
            subplot(3,2,5);
            plot(t,iBaseband,'b',t,qBaseband,'r')
            title('I and Q baseband waveforms')
            legend('I','Q')
        end
    end
end