classdef U1084ADigitizer < handle
% Contains paramaters and methods for U1084A Digitizer

    properties (SetAccess = private, GetAccess = public)
        address;    % PXI address
        instrID;    % ID
    end
    properties
        params;     % Parameters for digitizer
    end
    properties (Access = private)
        AqReadParameters;   % Internal struct for ReadIandQ() method
        maxAvg = 16777216;  % Maximum on-card averages
        maxSeg = 131072;   % Maximun segments
    end
    
    methods
        function self = U1084ADigitizer(address)
        % Initialize card
            self.address = address;
            % Initializes and returns instrID
            [status, self.instrID] = Aq_InitWithOptions(self.address, 0, 1, '');
            
            if status
                error('Initialization error for U1084A digitizer');
            end
                    
            % Clock settings: use INTERNAL clock
            status = AqD1_configExtClock(self.instrID, 0, 0, 1, 1, 1);
            % second parameter:  clock type (0 = int clock, 2 = ext 10 MHZ ref)
            % third parameter: inputthreshold in mV
            % last 3 parameters are unused

            % Setting tp external clock always give error
            % unless threshold = 0 !?
            if status
                error('Error setting external clock for U1084A digitizer');
            end

            status = Aq_calibrate(self.instrID);
            if status
                error('Calibration error for U1084A digitizer');
            end
            
            % Set to averaging mode
            AqD1_configMode(self.instrID, 2, 0, 0);
          
            % Load default settings
            self.SetParams(paramlib.acqiris());
            display([class(self), ' object created.']);
        end
        function set.params(self, params)
            SetParams(self, params);
        end
        function params = get.params(self)
            params = GetParams(self);
        end

        % Declaration of all methods
        % Each method is defined in a separate file
        Finalize(self);	% Close card
        SetParams(self, params);	% Set card parameters
        params = GetParams(self);	% Get card parameters
        [IData, QData] = ReadIandQ(self);	% Acquire data from two channels
    end
end