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
            degree = str2double(name{2});
            
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
                if ~isnan(degree)
                    self.amplitude = degree/180;
                    self.rotation = degree/180*pi;
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
        
        function value = get.totalDuration(self)
            value = self.cutoff+self.buffer;
        end
        
        function g = gaussian(self, tAxis, tCenter)
            % given the time for the center of the pulse and a
            % time axis, generates the base gaussian waveform.
            g = self.amplitude.*exp(-(tAxis-tCenter).^2/(2*self.sigma^2));
        end
        
        function d = drag(self, tAxis, tCenter)
            % given the time for the center of the pulse and a
            % time axis, generates the drag waveform.     
            d = self.dragAmplitude ...
                *(-(tAxis-tCenter)/self.sigma) ...
                .*exp(-(tAxis-tCenter).^2/(2*self.sigma^2)+0.5);
        end
        
        function wc = applyGaussianCutoff(self, tAxis, tCenter, w)
            % zeros out values of waveform outside of cutoff and removes offset
            offset = self.amplitude*exp(-self.cutoff^2/(8*self.sigma^2));
            wc = (w-offset).*(tAxis>=(tCenter-self.cutoff/2)) ...
                           .*(tAxis<=(tCenter+self.cutoff/2));
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
            wc = (w-offset).*(tAxis>=(tCenter-self.cutoff/2)) ...
                           .*(tAxis<=(tCenter+self.cutoff/2));
        end
        
        function [iBaseband, qBaseband] = project(self, g, d)
            % find I and Q baseband using azimuth - g is main gaussian
            % waveform and d is drag waveform
            iBaseband = cos(self.azimuth).*g + sin(self.azimuth).*d;
            qBaseband = sin(self.azimuth).*g + cos(self.azimuth).*d;
        end
        
        function [iBaseband, qBaseband] = uwWaveformsSlow(self, tAxis, tCenter)
            % given just a time axis and pulse time, returns final baseband
            % signals. can be added to similar outputs from other gates to
            % form a composite waveform
            % NOTE: this method will be slow if used directly with a very
            % long waveform with high sampling rate.
            if strcmp(self.name,'Identity')
                iBaseband = zeros(1,length(tAxis));
                qBaseband = iBaseband;
                return
            end
            g = self.gaussian(tAxis, tCenter);
            d = self.drag(tAxis, tCenter);
            gc = self.applyGaussianCutoff(tAxis, tCenter, g);
            dc = self.applyDragCutoff(tAxis, tCenter, d);
            [iBaseband, qBaseband] = project(self, gc, dc);
        end
                
        function [iBaseband, qBaseband] = uwWaveforms(self, tAxis, tCenter)
            % given just a time axis and pulse time, returns final baseband
            % signals. can be added to similar outputs from other gates to
            % form a composite waveform
            % NOTE: provides speedup over slow version by using small
            % waveforms during intermediate calculations
            % 2nd NOTE: if tAxis input isn't 0:1/samplingRate:end then 
            % there might be a bug that I couldn't fix...
            if strcmp(self.name,'Identity')
                iBaseband = zeros(1,length(tAxis));
                qBaseband = iBaseband;
                return
            end
            samplingRate = 1/(tAxis(2)-tAxis(1));
%             % if tAxis doesn't start at zero, keep track of index
%             inputTimeAxisOffsetIndex = round(tAxis(1)*samplingRate);
            tStart = tCenter - self.totalDuration/2;
            tStop = tCenter + self.totalDuration/2;
            % calculate start and stop indices for nonzero elements.  includes boundary if it falls on a sample
            startInd = ceil(tStart*samplingRate);
            stopInd = floor(tStop*samplingRate);
%             startInd = find(tAxis >= tStart, 1);
%             stopInd = find(tAxis >= tStart, 1, 'last');
            % vector of nonzero indices
            nonZeroInd = startInd:stopInd;
            % vector of nonzero times
            nonZeroTimeAxis = (nonZeroInd-1)/samplingRate;
            % use short time axis to calculate the pulse waveform
            [iBasebandShort, qBasebandShort] = uwWaveformsSlow(self, nonZeroTimeAxis, tCenter);
            % place short pulse vector into large vector of zeros
%             startIndShifted = startInd-inputTimeAxisOffsetIndex
%             stopIndShifted = stopInd-inputTimeAxisOffsetIndex
            iBaseband = zeros(1,length(tAxis));
%             iBaseband(startIndShifted:stopIndShifted)=iBasebandShort;
            iBaseband(startInd:stopInd)=iBasebandShort;
            qBaseband = zeros(1,length(tAxis));
%             qBaseband(startIndShifted:stopIndShifted)=qBasebandShort;
            qBaseband(startInd:stopInd)=qBasebandShort;
        end
        
        function [iMod, qMod] = modWaveforms(self, tAxis, tCenter, qubitFreq)
            % speed up waveform generation by doing avoiding doing
            % modulation on entire long waveform.
            if strcmp(self.name,'Identity')
                iBaseband = zeros(1,length(tAxis));
                qBaseband = iBaseband;
                return
            end
            samplingRate = 1/(tAxis(2)-tAxis(1));
%             % if tAxis doesn't start at zero, keep track of index
%             inputTimeAxisOffsetIndex = round(tAxis(1)*samplingRate);
            tStart = tCenter - self.totalDuration/2;
            tStop = tCenter + self.totalDuration/2;
            % calculate start and stop indices for nonzero elements.  includes boundary if it falls on a sample
            startInd = ceil(tStart*samplingRate);
            stopInd = floor(tStop*samplingRate);
%             startInd = find(tAxis >= tStart, 1);
%             stopInd = find(tAxis >= tStart, 1, 'last');
            % vector of nonzero indices
            nonZeroInd = startInd:stopInd;
            % vector of nonzero times
            nonZeroTimeAxis = (nonZeroInd-1)/samplingRate;
            % use short time axis to calculate the pulse waveform
            [iBasebandShort, qBasebandShort] = uwWaveformsSlow(self, nonZeroTimeAxis, tCenter);
            iModShort = cos(2*pi*qubitFreq*nonZeroTimeAxis).*iBasebandShort;
            qModShort = sin(2*pi*qubitFreq*nonZeroTimeAxis).*iBasebandShort;
            % place short pulse vector into large vector of zeros
%             startIndShifted = startInd-inputTimeAxisOffsetIndex
%             stopIndShifted = stopInd-inputTimeAxisOffsetIndex
            iMod = zeros(1,length(tAxis));
%             iBaseband(startIndShifted:stopIndShifted)=iBasebandShort;
            iMod(startInd:stopInd)=iModShort;
            qMod = zeros(1,length(tAxis));
%             qBaseband(startIndShifted:stopIndShifted)=qBasebandShort;
            qMod(startInd:stopInd)=qModShort;
        end
        
        
%         function [iBaseband, qBaseband, startInd, stopInd] = uwWaveformsFast(self, samplingRate, tCenter)
%             % Generates short time vector based on sampling rate.  Returns
%             % the short waveform vector along with the indicies to be used 
%             % to add/insert the short waveform into a longer waveform based
%             % on the full time axis. This version never actually handles
%             % long vectors.
%             % example usage of outputs:  longWaveform(indStart:indStop) = longWaveform(indStart:indStop) + iBaseband;
%             tStart = tCenter - self.totalDuration/2;
%             tStop = tCenter + self.totalDuration/2;
%             % calculate start and stop indices for nonzero elements.  includes boundary if it falls on a sample
%             startInd = ceil(tStart*samplingRate);
%             stopInd = floor(tStop*samplingRate);
%             % vector of nonzero indices
%             nonZeroInd = startInd:stopInd;
%             % vector of nonzero times
%             nonZeroTimeAxis = (nonZeroInd-1)/samplingRate;
%             % use short time axis to calculate the pulse waveform
%             [iBaseband, qBaseband] = uwWaveformsSlow(self, nonZeroTimeAxis, tCenter);
%         end
            
            
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(self, stateIn)
            % given an input state vector act with unitary and return final state 
            stateOut = self.unitary*stateIn;
            stateTilt = 2*acos(abs(stateOut(1)));
            stateAzimuth = angle(stateOut(2))-angle(stateOut(1));
        end
        
        function s = toStruct(self)
            warning('off', 'MATLAB:structOnObject');
            s = struct(self);
            warning('on', 'MATLAB:structOnObject');
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
            title('gaussian pulse');
            subplot(3,2,3);
            plot(t,drag,'b',t,dragCutoff,t,buffer*max(drag),'k');
            title('drag pulse');
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
            plotlib.blochSpherePlot(ax, 0, 0);
            [~, stateTilt, stateAzimuth] = self.actOnState([1;0]);
            plotlib.blochSpherePlot(ax,stateTilt,stateAzimuth,'replot');
            subplot(3,2,5);
            plot(t,iBaseband,'b',t,qBaseband,'r')
            title('I and Q baseband waveforms')
            legend('I','Q');
        end
    end
end