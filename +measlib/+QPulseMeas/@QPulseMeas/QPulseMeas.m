classdef QPulseMeas < handle
% A (super)class for pulsed measurement
% Contains shared properties and methods for measurements
% with a single measurement pulse and an array of qubit drive pulses

% This class CANNOT be used by itself because the method "setWaveforms" is 
% defined as ABSTRACT. A specific type of measurement (e.g. T1 measurement) can
% inherit this class and define a concrete implementation of "setWaveforms".
% See QLifTime.T1 as a template.

    properties
        params; % Parameters for measurement
        instr; % Instruments for measurement
        data; % Measured data
        mPulse; % measure pulse
        qWaveforms; % an array of waveforms for AWG
    end

    methods
        function self = QPulseMeas()
            % Constructor, initialize all properties
            self.params = measlib.QPulseMeas.Params();
            self.instr = measlib.QPulseMeas.Instr();
            self.data = measlib.QPulseMeas.Data();
            self.mPulse = pulselib.measPulse();
        end
        
        run(self); % Run measurement
        
        function s = dataToStruct(self)
        % Convert measured data object to a struct
            s = self.data.toStruct();
        end
        
        function plotData(self)
        % Plot data
            measlib.QPulseMeas.plotData(self.data);
        end
    end
    
    methods (Access = protected, Abstract)
    % Set up the drive and measurement waveforms for AWG
    
    % This method must be defined in a subclass. It should define the "self.mPulse" object,
    % and its corresponding waveform. It should also define the "self.qWaveforms" array, 
    % with odd rows for the inphase and even rows for the quadrature.
        setWaveforms(self);
    end   
    
    methods (Access = protected)
    % Set up all the instruments except qpulsegen
    % qpulsegen will be set in self.run() method
        setInstr(self);
    end
end