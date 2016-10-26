classdef M9330AWG < handle
% Contains paramaters and methods for M9930A AWG

    properties (SetAccess = private, GetAccess = public)
        address; % PXI address
        instrhandle; % Handle for the instrument
    end
    properties (Access = public)
        samplingrate; % Default = 1.25 GHz, can be reduced by factors of 2^n, 0<=n<=10
        waveform1 = zeros(1, 256); % Minimum length is 128
        waveform2 = zeros(1, 256);
        timeaxis = (0:255)*0.8e-9;
        marker1 = zeros(1, 256); % Marker 1
        marker2 = zeros(1, 256);% Marker 2
        mkrauto = 1;
        mkr1offset = 0;
        mkr2offset = 0;
        mkraddwidth = 32;
        CH1MAXAMP = 32767;  % Maximum value = 32767
        CH2MAXAMP = 32767;  % Maximum value = 32767
        TRIGINPORT = 1;	% Port number for trigger input
        MKR1PORT = 2;	% Port number for marker 1 output
        MKR2PORT = 4;	% Port number for marker 2 output
        TRIGOUTPORT = 1;	% Port number for trigger output
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
            display([class(self), ' object created.']);
        end
        
        function set.samplingrate(self, samplerate)
            SetSampleRate(self, samplerate);
        end
        
        function samplingrate = get.samplingrate(self)
            samplingrate = GetSampleRate(self);
        end
        
        % Declaration of all methods
        % Each method is defined in a separate file
        SetSampleRate(self, samplerate); % Set sampling rate
        samplingrate = GetSampleRate(self); % Get sampling rate
        AutoMarker(self); % Automatically create markers
        Generate(self); % Load waveforms and markers, generate output
        Stop(self); % Stop output
        GenerateRaw(self, waveforms, markers); % Low level method for waveform generation
        SyncWith(self, master); % Synchronize with a master AWG
        Finalize(self); % Close instrhandle
    end
    
    methods (Access = protected)
        Initialize(self);
    end
end
