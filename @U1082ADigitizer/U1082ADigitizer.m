classdef U1082ADigitizer < handle
% Contains paramaters and methods for U1082A Digitizer

    properties (SetAccess = private, GetAccess = public)
        address;    % PXI address
        instrID;    % ID
    end
    properties (Dependent)
        params;     % Parameters for digitizer
    end
    properties (Access = private)
        AqReadParameters;   % Internal struct for ReadIandQ() method
    end
    
    methods
        function card = U1082ADigitizer(address)
        % Initialize card
            card.address = address;
            % Initializes and returns instrID
            [status, card.instrID] = Aq_InitWithOptions(card.address, 0, 0, 'asbus = false');
             if status ~= 0
                display('Initialization error for U1082A digitizer');
                return
            end   
                    
            % Clock settings
            AqD1_configExtClock(card.instrID, 2, 1000, 1, 1, 1);
            % second parameter:  clock type (2 = ext 10 MHZ ref)
            % third parameter: inputthreshold in mV,
            % last 3 parameters are unused
            
            status = Aq_calibrate(card.instrID);
            if status ~= 0
                display('Calibration error for U1082A digitizer');
                return
            end
            
            % Set to averaging mode
            AqD1_configMode(card.instrID, 2, 0, 0);

            % Trigger settings
            AqD1_configTrigClass(card.instrID, 0, hex2dec('80000000'), 0, 0, 0.0, 0.0);
            % second parameter = 0 sets trigclass tp edge trigger
            % third parameter = '80000000' sets trigsource to external trigger 1
            % last 4 parameters are unused
            
            trigLevel = 500; % trigger level in mV
            AqD1_configTrigSource(card.instrID, -1, 0, 0, trigLevel, 0.0);
            % second parameter = -1 sets trigger channel to external sources
            % third parameter = 0/1 sets trigger coupling to DC/AC
            % fourth parameter = 0/1/2/3 sets trigger slope to 
            %                    positive/negative/out of window/into window
            % fifth parameter sets trigger level
            % sixth parameter sets trigger level 2 when window trigger is used
            card.SetParams(card.params);
        end
        function set.params(card, params)
            SetParams(card, params);
        end
        function params = get.params(card)
            params = GetParams(card);
        end

        % Declaration of all methods
        % Each method is defined in a separate file
        Finalize(card);	% Close card
        SetParams(card, params);	% Set card parameters
        params = GetParams(card);	% Get card parameters
        [IData, QData] = ReadIandQ(card);	% Acquire data from two channels
    end
end
