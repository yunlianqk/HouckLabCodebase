classdef Data
% Raw and processed data for pulsed measurements

    properties
        meastype = []; % A string that describes the measurement
        rawdataI = []; % raw data
        rawdataQ = [];
        intdataI = []; % integrated data
        intdataQ = [];
        tAxis = []; % Time axis of digitizer, corresponding to columns in rawdata
        dataAxis = []; % Corresponds to rows in rawdata
        tRange = []; % The start and end time for data integration
        intFreq = []; % Intermediate frequency when using heterodyne
    end
    
    methods
        function s = toStruct(self)
        % Converts data object to a struct
            warning('off', 'MATLAB:structOnObject');
            s = struct(self);
            warning('on', 'MATLAB:structOnObject');
        end
        
        function [intdataI, intdataQ] = integrate(self)
        % Integrate data
            [intdataI, intdataQ] = measlib.QPulseMeas.integrateData(self);
        end

        function plot(self)
        % Plot data
            measlib.QPulseMeas.plotData(self);
        end
    end
end