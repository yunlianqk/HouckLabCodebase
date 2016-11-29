classdef SweepM8195 < handle
    % A super class for measurements with M8195A AWG and M9703A digitizer
    
    properties
        experimentName;
        % Pulse construction parameters
        pulseCal;
        sequences;
        measurement;
        % Pulse timing parameters
        measStartTime; 
        sequenceEndTime;
        waveformEndTime;
        % Use upconversion/direct synthesis for measurement pulse
        cavitybaseband = 0;
        % Frequency sweep parameters
        cavityFreq = [];
        qubitFreq = [];
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
    end
    
    methods
        function self = SweepM8195(pulseCal)
            self.pulseCal = pulseCal;
            name = strsplit(class(self), '.');
            self.experimentName = name{end};
        end
        
        SetUp(self);
        Download(self);
        Run(self);
        Save(self, path);
        
        LoadGateSweep(self, segsize);
        LoadQubitSweep(self, segsize);
        LoadCavitySweep(self, segsize);
        RunGateSweep(self);
        RunCavitySweep(self);
        RunHistogram(self);
    end
end