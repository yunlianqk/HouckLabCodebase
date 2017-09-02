classdef M9703ADigitizer64 < handle
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
    end
    
    methods
        function self=M9703ADigitizer64(address)
        % Initialize card
            warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
            try
                self.address=address;
                % Path to IVI drivers
                addpath('C:\IVI\MATLAB');
                % Initialisation options
                initOptions = 'Simulate=false, DriverSetup= Trace=false, Cal=0, model=M9703A';	
                % Create driver instance
                self.instrID = icdevice('AgMD1_win64.mdd', self.address, 'optionstring', initOptions);		
             
                connect(self.instrID);

            catch exception
                disp(getReport(exception));
            end
            % Calibrate card
            % Calibration requires trigger source to be on
            disp('Calibrating...')
            invoke(self.instrID.Instrumentspecificcalibration,...
                'calibrationselfcalibrate',4,0);   % fast cal
            disp('Calibration Complete')
            
            % Load default settings
            self.SetParams(paramlib.m9703a());
            display([class(self), ' object created.']);
            warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
        end
        
        function set.params(self, params)
            SetParams(self, params); %trying to set hardware
            
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
        [IData, QData] = ReadIandQ(self,awg,PlayList);	% Acquire data from two channels
%         [IData, QData, I2Data, Q2Data] = Read4ChannelIandQ(self,awg,PlayList);	% Acquire data from two channels
        [Idata,Isqdata,Qdata,Qsqdata] = ReadIandQcomplicated(self,awg,PlayList);	% includes background subtraction
        [Idata,Qdata] = ReadIandQsingleShot(self, awg, PlayList);
        dataArray = ReadChannels(self, chList);  % Acquire data from desired channels
        dataArray_v2 = ReadChannels_v2(self, chList);  % Acquire data from desired channels
        dataArray_v3 = ReadChannels64(self, chList);
        dataArray_v4 = ReadChannels64_multiSegment(self, chList);
        Data = Read64_multiSeg(self, channel);
%         SetParam_MS(self, params);
    end
end