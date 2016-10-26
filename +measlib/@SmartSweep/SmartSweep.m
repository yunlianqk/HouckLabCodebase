classdef SmartSweep < handle
    % Generic parameter sweep measurement for AWG-modulated
    % vector generator and digitizer
    
    properties
        name = [];  % Name of the measurement
        % Main parameters
        rffreq = [];  % rfgen frequency
        rfpower = [];  % rfgen power
        rfcw = 1;  % 1: rfgen in continuous mode; 0: rfgen in modulation mode
        specfreq = [];  % specgen frequency
        specpower = [];  % specgen power
        speccw = 1;  % 1: specgen in continuous mode; 0: specgen in modulation mode
        intfreq = 0;  % Intermediate frequency between logen and rfgen
        lopower = 11;  % logen power
        yoko1volt = [];  % yoko1 voltage
        gateseq = [];  % gate sequences for pulsegen1 channel1 and channel 2
        measpulse = [];  % measurement pulse for pulsegen2 channel1
        fluxseq = [];  % gate sequences for pulsegen2 channel1
        
        % General pulse timing parameters
        startBuffer = 5e-6;  % delay after start before pulses can occur
        measBuffer = 200e-9;  % delay gate pulse and measurement pulse
        endBuffer = 5e-6;  % buffer after measurement pulse
        
        % The following five parameters can be used to 
        % directly pass waveform data to AWGs
        awgtaxis = [];  % Time axis for pulsegen1 and pulsegen2
        awgch1 = [];  % wav
        awgch2 = [];
        awgch3 = [];
        awgch4 = [];
        
        % Acquisition and trigger parameters
        waittime = 0.1;  % Wait time btw instrument setup and acquisition
        trigperiod = 'auto';  % Trigger period
        carddelayoffset = 0;  % Fine tuning of card delay
        cardacqtime = 'auto';  % Duration of acquistion
        cardavg = 10000;  % Averaging
        bgsubtraction = [];  % Background subtraction
        
        % Acquired and processed data
        IQdata = measlib.IQData();  % Rawdata object
        intrange = [];  %  Time-domain integration window
        ampI = [];  % Demodulated amp and phase of I and Q
        ampQ = [];
        phaseI = [];
        phaseQ = [];
        
        % Plot setup
        plotsweep1 = 1;  % Plot on/off for inner loop
        plotsweep2 = 1;  % Plot on/off for outer loop
        plotupdateinterval = 10;  % Plot update interval for inner loop
    end
    
    properties (Access = private)
        lofreq = [];  % logen frequency, equals rffreq + intfreq
        numSweep1 = 1;  % Size of outer loop
        numSweep2 = 1;  % Size of inner loop
        sweep1data = {};  % parameters for outer loop
        sweep1func = {};  % function handles for outer loop
        sweep2data = {};  % parameters for inner loop
        sweep2func = {};  % function handles for outer loop
        sweep3data = {};  % parameters for "2D" inner loop
        sweep3func = {};  % function handles for "2D" inner loop
        acqsigfunc = [];  % function handle for signal acquisition
        acqbgfunc = [];  % function handle for background acquisition
        plot1func = [];  % function handle for outer loop plot
        plot2func = [];  % function handle for inner loop plot
        % Default settings for CW measurements
        autotrigperiod = 25e-6;
        autocarddelay = 1e-6;
        autocardacqtime = 20e-6;
        % Pulse timing parameters
        seqEndTime = 0;
        measStartTime = 0;
        waveformEndTime = 0;
    end
    
    methods
        function self = SmartSweep(params)
            if nargin == 0
                params = [];
            end
            if isstruct(params)
                for p = fieldnames(params)'
                    if isprop(self, p{:})
                        self.(p{:}) = params.(p{:});
                    end
                end
            end
            if isobject(params)
                for p = properties(params)'
                    if isprop(self, p{:})
                        self.(p{:}) = params.(p{:});
                    end
                end
            end
        end
        
        function SetUp(self)
            self.SetPulse();
            self.SetSweep();
            self.InitInstr();
            self.SetOutput();
        end
        
        SetPulse(self);
        SetSweep(self);
        InitInstr(self);
        SetOutput(self);
        Run(self);      
    end
end