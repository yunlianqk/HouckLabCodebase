classdef SmartSweep < handle
    % Generic parameter sweep measurement for AWG-modulated
    % vector generator and digitizer
    
    properties
        name = [];  % Name of the measurement
        % Generator sweep params
        rffreq = [];  % rfgen frequency
        rfpower = [];  % rfgen power
        rfphase = [];  % rfgen phase
        rfcw = 1;  % 1: rfgen in continuous mode; 0: rfgen in modulation mode
        specfreq = [];  % specgen frequency
        specpower = [];  % specgen power
        specphase = [];  % specgen phase
        speccw = 1;  % 1: specgen in continuous mode; 0: specgen in modulation mode
        intfreq = 0;  % Intermediate frequency between logen and rfgen
        lopower = 11;  % logen power
        lophase = [];  % logen phase
        % Additional generator sweep params
        fluxfreq = [];
        fluxpower = [];
        fluxphase = [];
        fluxcw = [];
        spec2freq = [];
        spec2power = [];
        spec2phase = [];
        spec2cw = [];
        % Yoko sweep params
        yoko1volt = [];  % yoko1 voltage
        yoko2volt = [];  % yoko2 voltage
        % AWG pulse sequence sweeep params
        pulseCal = [];
        gateseq = [];  % gate sequences for pulsegen1 channel1 and channel 2
        measpulse = [];  % measurement pulse for pulsegen2 channel1
        fluxseq = [];  % gate sequences for pulsegen2 channel1
        normalization = 0;
        
        % General pulse timing parameters
        startBuffer = 1e-6;  % delay after start before pulses can occur
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
        
        % Plotting options
        plotsweep1 = 1;  % Plot on/off for inner loop
        plotsweep2 = 1;  % Plot on/off for outer loop
        plotupdate = 10;  % Plot update interval for inner loop
        
        % Saving options
        autosave = 0;
        savepath = 'D:\Data\';
        savefile;
        
        % Measured results
        result = struct('Idata', [], ... % rawdata
                        'Qdata', [], ...
                        'ampI', [], ... % integrated/demodulated data
                        'ampQ', [], ...
                        'phaseI', [], ...
                        'phaseQ', [], ...
                        'colAxis', [], ... % Corresponds to columns in rawdata
                        'rowAxis', [], ... % Corresponds to rows in rawdata
                        'intRange', [], ... % The start and end time for data integration
                        'intFreq', [], ... % Intermediate frequency when using heterodyne
                        'sampleinterval', []);
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
        function self = SmartSweep(config)
            % experimentName is the same as the (sub)class name
            name = strsplit(class(self), '.');
            self.name = name{end};
            % Update properties specified in config
            if nargin == 0
                config = [];
            end
            % If config is a struct
            if isstruct(config)
                for p = fieldnames(config)'
                    if isprop(self, p{:})
                        self.(p{:}) = config.(p{:});
                    end
                end
            end
            % If config is an object
            if isobject(config)
                for p = properties(config)'
                    if isprop(self, p{:})
                        self.(p{:}) = config.(p{:});
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
        Save(self);
        Plot(self, fignum);
        Integrate(self);
        Normalize(self);
    end
end