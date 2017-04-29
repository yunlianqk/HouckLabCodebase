classdef M9330AWG < handle
% Contains paramaters and methods for M9930A AWG

    properties (SetAccess = private, GetAccess = public)
        address; % PXI address
        instrhandle; % Handle for the instrument
    end
    properties (Access = public)
        samplingrate; % Default = 1.25 GHz, can be reduced by factors of 2^n, 0<=n<=10
        timeaxis = (0:255)*0.8e-9; % Time axis
        waveform1 = zeros(1, 256); % Waveforms
        waveform2 = zeros(1, 256);
        marker1 = zeros(1, 256); % Markers
        marker2 = zeros(1, 256);
        marker3 = zeros(1, 256);
        marker4 = zeros(1, 256);
        mkrauto = 1; % Automatic marker option
        mkroffset = 0; % Shift marker with respect to waveform
        mkraddwidth = 32; % Additional marker width outside waveform
        TRIGINPORT = 1;	% Port number for trigger input
        OUTPUTCONFIG = 2;	% 0 = differential, gain can be 0.340 to 0.500
                           	% 1 = single-ended, gain can be 0.170 to 0.250 
                         	% 2 = amplified (single-ended), gain can be 0.340 to 0.500
    end
    
    methods
        function self = M9330AWG(address)
        % Open instrhandle
            
            % Check that MATLAB is 32-bit
            if isempty(strfind(mexext(), '32'))
                error('AWG M9330A only works with 32-bit MATLAB');
            end
            self.address = address;
            self.instrhandle = instrument.driver.AgM933x();
            self.Initialize();
            disp([class(self), ' object created.']);
        end
        
        function set.samplingrate(self, samplerate)
            SetSampleRate(self, samplerate);
        end
        
        function samplingrate = get.samplingrate(self)
            samplingrate = GetSampleRate(self);
        end
        
        % Declaration of all methods
        % Each method is defined in a separate file
        Initialize(self);
        SetSampleRate(self, samplerate); % Set sampling rate
        samplingrate = GetSampleRate(self); % Get sampling rate
        Generate(self); % Load waveforms and markers, generate output
        Stop(self); % Stop output
        GenerateRaw(self, waveforms, markers); % Low level method for waveform generation
        SyncWith(self, master); % Synchronize with a master AWG
        s = Info(self); % Display instrument information
        Finalize(self); % Close instrhandle
    end
    
    methods (Hidden)
        % Deprecated methods
        AutoMarker(self);
    end
end
