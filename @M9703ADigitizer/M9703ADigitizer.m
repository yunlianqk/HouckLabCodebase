classdef M9703ADigitizer < handle
% Contains parameters and methods for M9703A Digitizer
    
    properties (SetAccess = private, GetAccess = public)
        address;    % PXI address
        instrID;    % ID
    end
    properties (Access = public)
        params;     % Parameters for digitizer, real-time updated whenever
                    % self.GetParams or self.get.params is called
    end
    properties (Access = private)
        % Parameters that are NOT hardware coded are stored here to prevent
        % them from being cleared when self.GetParams() is called
        ChI;
        ChQ;
%         ChI2;
%         ChQ2;
        segments;
        trigPeriod;
        waittrig = 0;
    end
    
    methods
        function self=M9703ADigitizer(address)
        % Initialize card
            warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
            try
                self.address=address;
                % Path to IVI drivers
                 addpath('C:\IVI\MATLAB');
                % Create driver instance
                self.instrID = instrument.driver.AgMD1();
            
                % Initialisation options
                initOptions = 'Simulate=false, DriverSetup= Trace=false, Cal=0, model=M9703A';			
                idquery = true;
                reset   = true;
            
                % Initialize driver instance
                self.instrID.Initialize(self.address,idquery,reset,initOptions);
                
                % Print a few IIviDriver.Identity properties
                disp(['Identifier:      ', self.instrID.Identity.Identifier]);
                disp(['Revision:        ', self.instrID.Identity.Revision]);
                disp(['Vendor:          ', self.instrID.Identity.Vendor]);
                disp(['Description:     ', self.instrID.Identity.Description]);
                disp(['InstrumentModel: ', self.instrID.Identity.InstrumentModel]);
                disp(['FirmwareRev:     ', self.instrID.Identity.InstrumentFirmwareRevision]);
            catch exception
               disp(getReport(exception)); 
            end            
        % Calibrate card
        % Calibration requires trigger source to be on
            self.instrID.DeviceSpecific.Calibration.SelfCalibrate(0,1); % 0=AgMD1CalibrateTypeFull
            
            % Load default settings
            self.SetParams(paramlib.m9703a());
            display([class(self), ' object created.']);
            warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
        end
        
        function set.params(self, params)
            SetParams(self, params);
        end
        
        function params= get.params(self)
            params = GetParams(self);
        end
        
        % Declaration of all methods
        % Each method is defined in a separate file
        Finalize(self);	% Close card
        iscorrect = CheckParams(~, params);  % Check card parameters
        SetParams(self, params);	% Set card parameters
        params = GetParams(self);	% Get card parameters
        WaitTrigger(self);  % Wait for trigger to synchronize multisegment acquisition
        [IData, QData] = ReadIandQ(self);	% Acquire data from two channels
        [Idata,Isqdata,Qdata,Qsqdata] = ReadIandQcomplicated(self);	% includes background subtraction
        [Idata,Qdata] = ReadIandQsingleShot(self, awg, PlayList);
        dataArray = ReadChannels(self, chList);  % Acquire data from desired channels
    end
end