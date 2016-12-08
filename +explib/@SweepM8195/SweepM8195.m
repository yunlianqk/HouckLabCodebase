classdef SweepM8195 < handle
    % A super class for measurements with M8195A AWG and M9703A digitizer
    % All classes in explib are subclass of this
    
    % To use this class (and its subclasses):
    % Name M8195AWG object as global variable 'awg'
    % Name M9703ADigitizier object as global varaiable 'card'
    
    % For cavity pulse in upconversion mode:
    % Name E8267DGenerator object as global variable 'rfgen'
    
    % For external LO generator:
    % Name E8267DGenerator object as global variable 'logen'
    properties
        experimentName;
        % Pulse construction parameters
        pulseCal;
        sequences;
        measurement;
        % Pulse timing parameters
        % These are calculated automatically during pulse generation
        % No need to specify
        measStartTime; 
        sequenceEndTime;
        waveformEndTime;
        % AWG channel mapping
        qubitchannel = 1;
        cavitychannel = 2;
        lochannel = [];
        % Use upconversion/direct synthesis for measurement pulse
        cavitybaseband = 0;
        % Frequency sweep parameters
        % Leave as blank unless you need to sweep qubit/cavity frequency
        cavityFreq = [];
        qubitFreq = [];
        bgFreq = [];
        % Measurement parameters
        softwareAverages = 10;
        cardAverages = 20;
        bgsubtraction = 1;
        normalization = 0;
        histogram = 0;
        histrange = [];
        numbins = [];
        doPlot = 1;
        updatePlot = 10;
        % AWG playlist
        playlist;
        % Measured result
        result;
        % Save options
        autosave = 0;
        savepath = 'C:\Data\';
        savefile;
    end
    
    methods
        function self = SweepM8195(pulseCal, config)
            % gate calibration results are stored in pulseCal
            self.pulseCal = pulseCal;
            % experimentName is the same as the (sub)class name
            name = strsplit(class(self), '.');
            self.experimentName = name{end};
            % Update properties specified in config
            if nargin == 1
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
        
        SetUp(self);  % Set up equipments
        Download(self);  % Download waveforms into AWG
        Run(self);  % Generate waveforms and acquire data
        Plot(self);  % Plot measured data
        Save(self, path);  % Save measured data
    end
    
    methods (Access = protected)
        % Internal functions that contain detailed implementations
        LoadGateSweep(self, segsize);
        LoadQubitSweep(self, segsize);
        LoadCavitySweep(self, segsize);
        RunGateSweep(self);
        RunCavitySweep(self);
        RunHistogram(self);
        PlotGateSweep(self);
        PlotCavitySweep(self);
        PlotQubitSweep(self);
        PlotHistogram(self);
    end
end