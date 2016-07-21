classdef M9703ADigitizer < handle
% Contains parameters and methods for M9703A Digitizer
    
    properties (SetAccess = private, GetAccess = public)
        address;    % PXI address
        instrID;    % ID
    end
    properties (Access = public)
        params;     % Parameters for digitizer
    end
%     properties (Access = private)
%         ReadParameters;     % Internal struct for ReadIandQ() method
%         timeout;
%     end
    
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
            self.params = paramlib.m9703a();
            display([class(self), ' object created.']);
            warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
        end
        
        % Declaration of all methods
        % Each method is defined in a separate file
        Finalize(self);	% Close card
        SetParams(self, params);	% Set card parameters
        params = GetParams(self);	% Get card parameters
        [IData, QData] = ReadIandQ(self);	% Acquire data from two channels
    end
end