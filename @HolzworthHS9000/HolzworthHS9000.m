% Holzworth multi-channel source driver
%
% Adapted from https://github.com/BBN-Q/Qlab/tree/develop/common/%2BdeviceDrivers
% % Author: Blake Johnson
%
% % Copyright 2013 Raytheon BBN Technologies
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
% % % limitations under the License.

classdef HolzworthHS9000 < handle
    properties
        address; % Needs to be in the form of 'model-serial-channel'
                 % e.g., 'HS9004A-527-1'
        output; % 0/1
        freq; % in Hz
        power; % in dBm
        phase; % in radians
        modulation; % 0/1
        ref; % (internal 100MHz) 'int', (external) '10MHz', or (external) '100MHz'
    end
    
    properties (SetAccess = private)
        temperature; % Temperature
    end
    
    properties (Hidden, SetAccess = private)
        channel; % Channel number
        % The following properties are not supported by hardware
        % They are kept here as placeholder to make the interface
        % consistent with E8267D class
        alc = 0;
        pulse = 0;
        iq = 0;
    end

    methods
        function self = HolzworthHS9000(address)
            % Initialize instrument
            self.address = address;
            % Load driver library
            self.LoadDriver();
            % Try connection
            success = calllib(self.lib, 'openDevice', address);
            if success > 0
                disp([class(self), ' object created.']);
            else
                error([class(self), ' object initialization failed. ', ...
                      'Address: ', address]);
            end
            % Get channel number
            tempstr = strsplit(address, '-');
            self.channel = str2double(tempstr{3});
            % Set reference clock
            self.ref = '10MHz';
            % Turn off modulation
            self.modulation = 0;
        end
        
        function Finalize(self)
            % Close instrument
            calllib(self.lib, 'close_all');
        end
        
        function out = write(self, command)
            % Send command to instrument and get response
            if strfind(command, 'REF')
                % If command is setting reference, do not specify channel
                out = calllib(self.lib, 'usbCommWrite', self.address, command);
            else
                % Otherwise specify channel
                out = calllib(self.lib, 'usbCommWrite', self.address, ...
                              [':CH', num2str(self.channel), command]);
            end
        end

        function s = Info(self)
            % Return instrument info
            s = self.write(':IDN?');
        end
        
        function Reset(self)
            % Reset instrument
            self.write('*RST');
        end

        % property getters/setters
        function set.output(self, output)
            switch lower(output)
                case {1, 'on'}
                    self.PowerOn();
                case {0, 'off'}
                    self.PowerOff();
                otherwise
                    disp('Do not give me gibberish!');
            end
        end
        
        function out = get.output(self)
            out = self.write(':PWR:RF?');
        end
        
        function set.freq(self, freq)
            % Frequency in Hz
            SetFreq(self,freq);
        end
        
        function freq = get.freq(self)
            % :FREQ? returns a string of the form XX.X MHz
            % so, we convert it to a numeric value in Hz
            freq = GetFreq(self);
        end
        
        function set.power(self, power)
            SetPower(self,power);
        end
        
        function power = get.power(self)
            power = GetPower(self);
        end
        
        function set.phase(self, phase)
            SetPhase(self, phase);
        end
        
        function phase = get.phase(self)
            phase = GetPhase(self);
        end
        
        function set.modulation(self, mod)
            switch lower(mod) % put mod in lowercase
                case {1, 'on'}
                    % for now Pulse modulation is hardcoded here
                    % the instrument has AM, FM, Phase modulation options too
                    self.ModOn();
                case {0, 'off'}
                    self.ModOff();
                otherwise
                    disp('For now I only handle on and off');
            end
        end
        
        function modulation = get.modulation(self)
            modulation = self.write(':MOD:MODE?');
        end
        
        function set.alc(~, ~)
            % Not supported by hardware
            % A place holder to make it compatible with E8267D generator
        end
        
        function alc = get.alc(~)
            % Not supported by hardware
            % A place holder to make it compatible with E8267D generator
            alc = 0;
        end
        
        function set.pulse(self, pulse)
            % Same as modulation
            if pulse
                self.ModOn();
            else
                self.ModOff();
            end
        end
        
        function pulse = get.pulse(self)
            % Same as modulation
            switch self.modulation
                case 'OFF'
                    pulse = 0;
                otherwise
                    pulse = 1;
            end
        end

        function set.ref(self, ref)
            % Allowed values for ref:
            % (internal 100MHz): 'INT'
            % (external 10MHz): '10MHz'
            % (external 100MHz): '100MHz'
            switch upper(ref)
                case 'INT'
                    self.write(':REF:INT:100MHz');
                case '10MHZ'
                    self.write(':REF:EXT:10MHz');
                case '100MHZ'
                    self.write(':REF:EXT:100MHz');
                otherwise
                    error('''ref'' should be one of ''INT'', ''10MHz'' or ''100MHz''.');
            end
            self.ref = ref;
        end
        
        function out = get.ref(self)
            % Get reference clock source
            out = self.write(':REF:STATUS?');
        end
        
        function temp = get.temperature(self)
            % Get temperature
            temp = sscanf(self.write(':TEMP?'), 'Temp = %s');
        end
        % Declaration of all other methods
        % Each method is defined in a separate file        
        SetFreq(self, freq);
        SetPower(self, power);
        SetPhase(self, phase);
        
        freq = GetFreq(self);
        power = GetPower(self);
        phase = GetPhase(self);
        
        PowerOn(self);
        PowerOff(self);
        
        ModOn(self);
        ModOff(self);
    end

    methods (Static)
        function devices = FindDevices()
            % Returns a string containing all connected instruments
            HolzworthHS9000.LoadDriver();
            devices = calllib(HolzworthHS9000.lib, 'getAttachedDevices');
        end
    end
    
    methods (Static, Hidden)
        % Define the alias for the driver library as a static property
        function lib = lib()
            lib = 'HolzworthMulti';
        end
        
        function LoadDriver()
        % Load the drive library if necessary
        % The .dll, .h and HolzworthProto.m files are in ..\drivers
        % And added to path in ..\setpath.m
            if ~libisloaded(HolzworthHS9000.lib)
                switch computer()
                    % The driver supports 32 or 64 bit Windows system
                    case 'PCWIN64'
                        libname = 'HolzworthMulti64.dll';
                    case 'PCWIN'
                        libname = 'HolzworthMulti32.dll';
                    otherwise
                        error('Your platform is not supported')
                end
            loadlibrary(libname, @HolzworthProto, 'alias', HolzworthHS9000.lib);
            end
        end
        
        function UnloadDriver()
            % Unload the driver library
            if libisloaded(HolzworthHS9000.lib)
                unloadlibrary(HolzworthHS9000.lib);
            end
        end
    end
end