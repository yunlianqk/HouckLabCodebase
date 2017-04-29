classdef SmartSweep < handle
    % Generic parameter sweep measurement for AWG-modulated
    % vector generator and digitizer
    
    properties
        name = [];  % Name of the measurement
        % Generator sweep params
        rffreq = [];  % rfgen frequency
        rfpower = [];  % rfgen power
        rfphase = [];  % rfgen phase
        specfreq = [];  % specgen frequency
        specpower = [];  % specgen power
        specphase = [];  % specgen phase
        intfreq = 0;  % Intermediate frequency between logen and rfgen
        lopower = 11;  % logen power
        lophase = [];  % logen phase
        % Additional generator sweep params
        fluxfreq = [];
        fluxpower = [];
        fluxphase = [];
        spec2freq = [];
        spec2power = [];
        spec2phase = [];
        % Yoko sweep params
        yoko1volt = [];  % yoko1 voltage
        yoko2volt = [];  % yoko2 voltage
        % AWG pulse sequence sweeep params
        pulseCal = [];
        gateseq = [];  % gate sequences for pulsegen1 channel1 and channel 2
        measseq = [];  % measurement pulse for pulsegen2 channel1
        fluxseq = [];  % gate sequences for pulsegen2 channel1
        
        % General pulse timing parameters
        startBuffer = 1e-6;  % delay after start before pulses can occur
        measBuffer = 200e-9;  % delay gate pulse and measurement pulse
        endBuffer = 5e-6;  % buffer after measurement pulse
        
        % Acquisition and trigger parameters
        waittime = 0.1;  % Wait time btw instrument setup and acquisition
        trigperiod = 'auto';  % Trigger period
        carddelayoffset = 0;  % Fine tuning of card delay
        cardacqtime = 'auto';  % Duration of acquistion
        cardavg = 10000;  % Averaging
        bgsubtraction = [];  % Background subtraction
        normalization = 0;  % Use zero and pi pulse to normalize readout
        intrange = [];   % start and stop time for integration
        
        % Plotting options
        plotsweep1 = 1;  % Plot on/off for inner loop
        plotsweep2 = 1;  % Plot on/off for outer loop
        plotupdate = 10;  % Plot update interval for inner loop
        
        % Saving options
        autosave = 0;
        savepath = 'C:\Data\';
        savefile;
        
        % Measured results
        result = struct('dataI', [], ... % rawdata
                        'dataQ', [], ...
                        'ampInt', [], ... % integrated/demodulated data
                        'phaseInt', [], ...
                        'tAxis', [], ... % time axis for digitizer
                        'rowAxis', [], ... % rows axis for rawdata
                        'intRange', [], ... % start and stop time for integration
                        'intFreq', [], ... % intermediate frequency
                        'sampleinterval', []);
    end
    
    properties (Access = private)
        lofreq = [];  % logen frequency, equals rffreq + intfreq
        awgtaxis = [];  % Time axis for pulsegen1 and pulsegen2
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
            self.UpdateParams(config);
         end
        
        function SetUp(self)
            if isa(self.pulseCal, 'paramlib.pulseCal')
                self.UpdateParams(self.pulseCal);
            end
            self.SetPulse();
            self.SetSweep();
            self.InitInstr();
            self.SetOutput();
        end
        
        UpdateParams(self, config);
        SetPulse(self);
        SetSweep(self);
        InitInstr(self);
        SetOutput(self);
        Run(self);
        Save(self, filename);
        Plot(self, fignum);
        Integrate(self);
        Normalize(self);
    end

    methods (Static)
        obj = Load(filename);
    end
end