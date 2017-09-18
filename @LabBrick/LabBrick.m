% Labbrick signal generator
% Adapted from BBN codebase

% % Author(s): Blake Johnson
% % Date created: Tues Aug 2 2011
% 
% % Copyright 2010 Raytheon BBN Technologies
% %
% % Licensed under the Apache License, Version 2.0 (the "License");
% % you may not use this file except in compliance with the License.
% % You may obtain a copy of the License at
% %
% %     http://www.apache.org/licenses/LICENSE-2.0
% %
% % Unless required by applicable law or agreed to in writing, software
% % distributed under the License is distributed on an "AS IS" BASIS,
% % WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% % See the License for the specific language governing permissions and
% % limitations under the License.

classdef LabBrick < handle
    properties (SetAccess = private)
        address; % 4-digit serial number
    end

    properties
        freq;
        power;
        output;
        ref;
    end

    properties (SetAccess = private, Hidden)
        devID; % device ID for calling C API
        max_power = 10; % dBm
        min_power = -40; % dBm
        max_freq = 10e9; % Hz
        min_freq = 5e9; % Hz
    end

    properties (Hidden)
        % The following properties are not supported by hardware
        % They are kept here as placeholder to make the interface
        % consistent with E8267D class
        phase = 0;
        modulation = 0;
        alc = 0;
        pulse = 0;
    end

    methods
        %Constructor
        function self = LabBrick(address)
            self.LoadDriver();
            calllib(LabBrick.lib, 'fnLMS_SetTestMode', false);
            
            if ~isnumeric(address)
                address = str2double(address);
            end
            self.address = address;

            % find the devID of the Labbrick with the given serial number
            [serial_nums, devIDs] = self.FindDevices();
            self.devID = devIDs(serial_nums == address);
            if isempty(self.devID)
                error('Could not find a Labbrick with address %i', address);
            end
            % Get device info
            info = self.Info();
            if info.DEV_OPENED
                % If device is open, do nothing
                status = 0;
            else
                % Else open device
                status = calllib(self.lib, 'fnLMS_InitDevice', self.devID);
            end
            if status ~= 0
                error('Could not open device with id: %i, returned error %i', [self.devID status])
            end
            % Populate some device properties
            self.max_power = calllib(self.lib, 'fnLMS_GetMaxPwr', self.devID) / 4;
            self.min_power = calllib(self.lib, 'fnLMS_GetMinPwr', self.devID) / 4;
            self.max_freq = calllib(self.lib, 'fnLMS_GetMaxFreq', self.devID) * 10;
            self.min_freq = calllib(self.lib, 'fnLMS_GetMinFreq', self.devID) * 10;
            % Set reference clock source to external
            self.ref = 'EXT';
        end

        % Destructor
        function Finalize(self)
            if ~isempty(self.devID)
                status = calllib(self.lib, 'fnLMS_CloseDevice', self.devID);
                if status == 0
                    self.devID = [];
                end
            end
        end

		% Instrument parameter accessors
        % getters
        function freq = get.freq(self)
            freq = GetFreq(self);
        end
        
        function power = get.power(self)
            power = GetPower(self);
        end

        function output = get.output(self)
            output = GetOutput(self);
        end 

        function ref = get.ref(self)
            ref = GetRef(self);
        end
        
        function info = Info(self)
            info = self.GetStatus(self.devID);
        end

        % property setters
        function set.freq(self, freq)
            SetFreq(self,freq);
        end
        
        function set.power(self, power)
            SetPower(self, power);
        end
        
        function set.output(self, value)
            self.CheckDevID();
            switch lower(value)
                case {1, 'on'}
                    PowerOn(self);
                case {0, 'off'}
                    PowerOff(self);
                otherwise
                    disp('Input 1/on or 0/off to change device output state');
            end
        end

        function set.ref(self, ref)
            SetRef(self, ref);
        end
        
        
        % Declaration of all other methods
        % Each method is defined in a separate file  
        
        SetFreq(self, freq);
        SetPower(self, power);
        SetRef(self, ref);
        
        output = GetOutput(self);
        freq = GetFreq(self);
        power = GetPower(self);
        ref = GetRef(self);

        PowerOn(self);
        PowerOff(self);
    end

    methods (Static)
        function [serials, ids] = FindDevices()
        % Get a list of connected Labbricks
        % NB: There is a bug in the Labbrick DLL that causes
        % fnLMS_GetDevInfo to only return device IDs in order until it
        % encounters an opened device. Device IDs seem to be assigned in
        % serial number order, so for example, if you open 1690 (devID = 1), then a
        % device with serial number 1691 (devID = 2) will not show up in a subsequent
        % call to fnLMS_GetDevInfo. To deal with this, we store the IDs and
        % serial numbers in persistent variables, and only update them if
        % these lists are empty or if the number of connected devices increases
            LabBrick.LoadDriver();
            
            persistent devIDs serial_nums;

            if isempty(devIDs)
                num_devices = calllib(LabBrick.lib, 'fnLMS_GetNumDevices');
                devIDs = zeros(1, num_devices);
                serial_nums = zeros(1, num_devices);
                [~, devIDs] = calllib(LabBrick.lib, 'fnLMS_GetDevInfo', devIDs);
                for i = 1:num_devices
                    id = devIDs(i);
                    serial_nums(i) = calllib(LabBrick.lib, 'fnLMS_GetSerialNumber', id);
                end
            end
            ids = devIDs;
            serials = serial_nums;
        end    
    end

    methods (Static, Hidden)
        function lib = lib()
        % Define the alias for the driver library as a static property
            lib = 'vnx_fmsynth';
        end

        function LoadDriver()
        % Load the driver library
        % The .dll, .h and LabBrickProto.m files are in ..\drivers\LabBrick_driver
        % And added to path in ..\setpath.m
            if ~libisloaded(LabBrick.lib)
                loadlibrary('vnx_fmsynth.dll', @LabBrickProto,  'alias', LabBrick.lib);
            end
        end

        function UnloadDriver()
        % Unload the driver library
            if libisloaded(LabBrick.lib)
                unloadlibrary(LabBrick.lib);
            end
        end
        
        function status = GetStatus(devID)
        % Get device status
            code = calllib(LabBrick.lib, 'fnLMS_GetDeviceStatus', devID);
            % Status code defined in c header file
            status = struct('INVALID_DEVID', hex2dec('80000000'), ...
                            'DEV_CONNECTED', hex2dec('00000001'), ...
                            'DEV_OPENED', hex2dec('00000002'), ...
                            'SWP_ACTIVE', hex2dec('00000004'), ...
                            'SWP_UP', hex2dec('00000008'), ...
                            'SWP_REPEAT', hex2dec('00000010'), ...
                            'SWP_BIDIRECTIONAL', hex2dec('00000020'), ...
                            'PLL_LOCKED', hex2dec('00000040'), ...
                            'FAST_PULSE_OPTION', hex2dec('00000080'));
            % Use bit-wise and to get each status
            for f = fieldnames(status)'
                status.(f{:}) = (bitand(status.(f{:}), code) == status.(f{:}));
            end
            % Get device model name
            switch computer()
                case 'PCWIN'
                    status.MODEL_NAME = blanks(calllib(LabBrick.lib, 'fnLMS_GetModelName', devID, []));
                    [~, status.MODEL_NAME] = calllib(LabBrick.lib, 'fnLMS_GetModelName', devID, status.MODEL_NAME);
                case 'PCWIN64'
                    status.MODEL_NAME = blanks(calllib(LabBrick.lib, 'fnLMS_GetModelNameA', devID, []));
                    [~, status.MODEL_NAME] = calllib(LabBrick.lib, 'fnLMS_GetModelNameA', devID, status.MODEL_NAME);
            end
        end   
    end

    methods (Access = protected)
        function CheckDevID(self)
            if isempty(self.devID)
                error('Device is not initialized.');
            end
        end
    end
end