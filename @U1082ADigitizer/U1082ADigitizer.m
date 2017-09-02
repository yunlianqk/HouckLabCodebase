classdef U1082ADigitizer < handle
% Contains paramaters and methods for U1082A Digitizer

    properties (SetAccess = private, GetAccess = public)
        address;    % PXI address
        instrID;    % ID
        temperature;  % Temperature in degree C
    end
    properties
        params;     % Parameters for digitizer
    end
    properties (Access = private)
        AqReadParameters;  % Internal struct for ReadIandQ() method
        waittrig = 0;  % Set to 1 when waiting for trigger.
                       % Need this to synchronize multi-segment acquisition
        maxAvg = 65536;  % Maximum on-card averages
        maxSeg = 8191;   % Maximun segments
    end
    
    methods
        function self = U1082ADigitizer(address)
        % Initialize card
            self.address = address;
            % Initializes and returns instrID
            [status, self.instrID] = Aq_InitWithOptions(self.address, 0, 0, 'asbus = false');
             if status ~= 0
                error('U1082A digitizer failed to initialize');
            end   
                    
            % Clock settings
            AqD1_configExtClock(self.instrID, 2, 1000, 1, 1, 1);
            % second parameter:  clock type (2 = ext 10 MHZ ref)
            % third parameter: inputthreshold in mV,
            % last 3 parameters are unused
            
            status = Aq_calibrate(self.instrID);
            if status ~= 0
                display('Calibration error for U1082A digitizer');
                return
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
        function temp = get.temperature(self)
            [~, temp] = Aq_getInstrumentInfo(self.instrID, 'Temperature 0', 'integer');
        end
        % Declaration of all methods
        % Each method is defined in a separate file
        Finalize(self);	% Close card
        SetParams(self, params);	% Set card parameters
        params = GetParams(self);	% Get card parameters
        WaitTrigger(self);  % Wait for trigger
        [IData, QData] = ReadIandQ(self);	% Acquire data from two channels
        s = Info(self); % Display device information
    end
end
