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
        function self = singleGate(name, params)   
            % Constructor takes the name of the gate to create an object
            % params can also be passed to specify properties of the gate
            % params can be either a struct or a pulseCal object
            
            % If name or params is missing, use default values
            if nargin == 0
                name = 'Identity';
                params = [];
            end
            if nargin == 1
                params = [];
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
                               '"Identity", "Custom", "X180", "Ym90", etc.']);
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
                            
            if ~isempty(params)
            % Update properties if they are specified in params
            % params can be either a struct or a pulseCal object
                % List relevant fields/properties of params here 
                paramlist = {'sigma', 'cutoff', 'buffer', 'amplitude', 'dragAmplitude', ...
                             [self.name, 'Amplitude'], ...
                             [self.name, 'DragAmplitude'], ...
                             [self.name, 'Azimuth']};
                % List corresponding properites of self here
                % The two list must have the same length
                proplist = {'sigma', 'cutoff', 'buffer', 'amplitude', 'dragAmplitude', ...
                            'amplitude', 'dragAmplitude', 'azimuth'};
                for idx = 1:length(paramlist)
                    param = paramlist{idx};
                    prop = proplist{idx};
                    if isfield(params, param) || isprop(params, param)
                        self.(prop) = params.(param);
                    end
                end
                % Update 'azimuth' for negative X/Y rotation gates
                % if 'azimuth' for positive X/Y rotations gates are specified
                if strcmp(self.name, 'Xm90') && (isfield(params, 'X90Azimuth') || isprop(params, 'X90Azimuth'))
                    self.azimuth = params.X90Azimuth + pi;
                end
                if strcmp(self.name, 'Xm180') && (isfield(params, 'X180Azimuth') || isprop(params, 'X180Azimuth'))
                    self.azimuth = params.X180Azimuth + pi;
                end
                if strcmp(self.name, 'Ym90') && (isfield(params, 'Y90Azimuth') || isprop(params, 'Y90Azimuth'))
                    self.azimuth = params.Y90Azimuth + pi;
                end
                if strcmp(self.name, 'Ym180') && (isfield(params, 'Y180Azimuth') || isprop(params, 'Y180Azimuth'))
                    self.azimuth = params.Y180Azimuth + pi;
                end
            end
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
        
        function dc = applyDragCutoff(self, tAxis, tCenter, d)
            % zeros out values of waveform outside of cutoff 
            dc = d.*(tAxis>=(tCenter-self.cutoff/2)) ...
                  .*(tAxis<=(tCenter+self.cutoff/2));
        end
        
        function [iBaseband, qBaseband] = project(self, g, d)
            % find I and Q baseband using azimuth
            % g is main gaussian waveform and d is drag waveform
            iBaseband = cos(self.azimuth).*g - sin(self.azimuth).*d;
            qBaseband = sin(self.azimuth).*g + cos(self.azimuth).*d;
        end

        function [iBaseband, qBaseband] = uwWaveforms(self, tAxis, tStart)
            % Returns baseband signals for a given time axis and start time
            if strcmp(self.name, 'Identity')
                iBaseband = zeros(1, length(tAxis));
                qBaseband = iBaseband;
            else
                tCenter = tStart + self.totalDuration/2;
                g = self.gaussian(tAxis, tCenter);
                g = self.applyGaussianCutoff(tAxis, tCenter, g);
                d = self.drag(tAxis, tCenter);
                d = self.applyDragCutoff(tAxis, tCenter, d);
                [iBaseband, qBaseband] = project(self, g, d);
            end
        end

        function [stateOut, stateTilt, stateAzimuth] = actOnState(self, stateIn)
            % given an input state vector act with unitary and return final state 
            stateOut = self.unitary*stateIn;
            stateTilt = 2*real(acos(abs(stateOut(1))));
            stateAzimuth = angle(stateOut(2))-angle(stateOut(1));
        end
                
        function draw(self) % visualize - draw waveform and bloch vector
            % print some text
            display(['Gate name: ', self.name]);
            display(['azimuth: ', num2str(self.azimuth)]);
            display(['rotation: ', num2str(self.rotation)]);
            display('unitary rotation matrix:');
            disp(self.unitary);
            display(['Total pulse duration (including buffer): ', num2str(self.totalDuration), 's'])
            % create time axis
            pulseTime = self.totalDuration;
            t = linspace(-pulseTime, pulseTime, 5001);
            % create waveform
            g = self.gaussian(t, 0);
            gc = self.applyGaussianCutoff(t, 0, g);
            % create drag
            d = self.drag(t, 0);
            dc = self.applyDragCutoff(t, 0, d);
            % find I and Q baseband using azimuth
            [iBaseband, qBaseband] = project(self, gc, dc);
            % buffer
            window = (t>-pulseTime/2).*(t<pulseTime/2);
            % plot
            figure(712);
            subplot(3, 2, 1);
            plot(t, g, 'b', t, gc, 'r', t, window*max(g), 'k--');
            title('Gaussian pulse');
            subplot(3, 2, 3);
            plot(t, d, 'b', t, dc, t, window*max(d), 'k--');
            title('DRAG pulse');
            subplot(3, 2, [2, 4]);
            scatter3(iBaseband, qBaseband, t, [], 1:length(t), '.');
            axis square;
            plotMax = max([max(abs(iBaseband)), max(abs(qBaseband))]);
            if plotMax == 0
                plotMax = 1;
            end
            axis([-plotMax, plotMax, -plotMax, plotMax, t(1), -t(1)])
            title(self.name);
            xlabel('I');
            ylabel('Q');
            ax = subplot(3, 2, 6);
            plotlib.blochSpherePlot(ax, 0, 0);
            [~, stateTilt, stateAzimuth] = self.actOnState([1;0]);
            plotlib.blochSpherePlot(ax, stateTilt, stateAzimuth, 'replot');
            subplot(3, 2, 5);
            plot(t, iBaseband, 'b', t, qBaseband, 'r');
            title('I/Q baseband waveforms');
            legend('I', 'Q');
        end
    end
end