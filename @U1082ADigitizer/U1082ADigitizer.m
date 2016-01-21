classdef U1082ADigitizer < handle
% Contains paramaters and methods for U1082A Digitizer

    properties (SetAccess = private, GetAccess = public)
        address;
        instrID;
        AqReadParameters;
    end
    properties (Access = public)
        fullscale = 0.2;	% from 0.05 to 5 in 1,2,5,10 sequence
        sampleinterval = 1e-9;  % from 1 ns to 100 ms in 1,2,2.5,4,5,10 sequence  
        samples = 10000;
        averages = 30000;
        segments = 1;
        delaytime = 10e-6;
        couplemode = 'DC';
    end
    
    methods
        function card = U1082ADigitizer(address)
        % Initialize card
            card.address = address;
            addpath('C:\Program Files (x86)\Agilent\MD1\U10xx_Digitizers\bin', ...
                    'C:\Program Files (x86)\Agilent\MD1\U10xx_Digitizers\MATLAB\mex\functions');

            [status, card.instrID] = Aq_InitWithOptions(card.address, 0, 0, 'asbus = false');
            
            % instrumentID, clock type (2 = ext 10 MHZ ref), inputthreshold in mV,
            % trash, trash, trash (last 3 parameters not needed for card)
            status = AqD1_configExtClock(card.instrID, 2, 1000, 1,1,1);
            status = Aq_calibrate(card.instrID);
            
            % Set to averaging mode
            AqD1_configMode(card.instrID, 2, 0, 0);

            % Trigger settings
            trigLevel = 500; %trigger level in mV for external trigger source
            AqD1_configTrigClass(card.instrID, 0, hex2dec('80000000'), 0, 0, 0.0, 0.0);
            % second parameter = 0 sets trigclass tp edge trigger
            % third parameter = '80000000' sets trigsource to external trigger 1
            AqD1_configTrigSource(card.instrID, -1, 0, 0, trigLevel, 0.0);
            % second parameter = -1 sets trigchannel to external sources
            % third parameter = 0/1 set trigcoupling to DC/AC
        end

        % Declaration of all methods
        % Each method is defined in a separate file
        Finalize(card);	% Close card
        SetParams(card);	% Set card parameters
        GetParams(card);	% Get card parameters
        [IData, QData] = ReadIandQ(card);	% Acquire data from two channels
    end
end