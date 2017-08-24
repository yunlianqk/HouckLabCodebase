classdef SignalCoreSC5511A < handle
% Signal Core sc5511a32
    properties
        address; % In form of 8 character string
        instr; % pointer to instrument
        output; % 0/1
        ref; % 'EXT' or 'INT'
        freq; % in Hz
        power; % in dBm
    end
    
    properties (SetAccess = private)
        temperature; % Temperature
    end
    
    properties (Hidden)
        channel; % Channel number
        % The following properties are not supported by hardware
        % They are kept here as placeholder to make the interface
        % consistent with E8267D class
        phase; % in radians
        modulation; % 0/1
        alc = 0;
        pulse = 0;
        iq = 0;
    end

    methods
        function self = SignalCoreSC5511A(address)
            % Initialize instrument
            self.address = address;
            % Load driver library
            self.LoadDriver();
            if ~ismember(address, self.FindDevices())
                error('Device does not exist or is in use.');
            end
            % Call open_device to initialize
            self.instr = calllib(self.lib, 'sc5511a_open_device', address);
            if ~isempty(self.instr.Value.handle)
                disp([class(self), ' object created.']);
            else
                error([class(self), ' object initialization failed. ', ...
                      'Address: ', address]);
            end
            % Set reference clock
            self.ref = 'EXT';
        end
        
        function Finalize(self)
            % Close instrument
            if ~isempty(self.instr)
                success = calllib(self.lib, 'sc5511a_close_device', self.instr);
                if success == 0
                    self.instr = [];
                end
            end
        end
        
        function s = Info(self)
            % Returns info of all connected signal cores in vector
            s=self.address;
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
        
        function output = get.output(self)
            %return output status
            output = GetOutput(self);
        end
        
        function set.freq(self, freq)
            % Frequency in Hz
            SetFreq(self,freq);
        end
        
        function freq = get.freq(self)
            freq = GetFreq(self);
        end
        
        function set.power(self, power)
            SetPower(self,power);
        end
        
        function power = get.power(self)
            power = GetPower(self);
        end
        
        function set.ref(self, ref)
            SetRef(self, ref);
        end
        
        function ref = get.ref(self)
            % Get reference clock source
            ref = GetRef(self);
        end
        
        function temp = get.temperature(self)
            % Get temperature
            tempPointer = libpointer('singlePtr', 20.0);
            calllib(self.lib, 'sc5511a_get_temperature', self.instr, tempPointer);
            temp = tempPointer.Value;
        end
        
        % Declaration of all other methods
        % Each method is defined in a separate file        
        SetFreq(self, freq);
        SetPower(self, power);
        SetRef(self, ref);
        
        status = GetStatus(self);
        output = GetOutput(self);
        freq = GetFreq(self);
        power = GetPower(self);
        ref = GetRef(self);
        
        PowerOn(self);
        PowerOff(self);
    end

    methods (Static)
        function devices = FindDevices()
            % Returns a string containing all connected instruments
            SignalCoreSC5511A.LoadDriver();
            % Maximum number of devices
            maxnum = 10;
            % Create buffer for storing addresses
            buffer = {''};
            for ii = 1:maxnum
                buffer{ii} = ['00000000', 0];
            end
            address = libpointer('stringPtrPtr', buffer);
            % Call sc5511a_search_devices to get the addresses
            numDevs = calllib(SignalCoreSC5511A.lib, 'sc5511a_search_devices', address);
            if numDevs > 0
                devices = address.Value(1:numDevs);
            else
                devices = [];
            end
        end
    end
    
    methods (Static, Hidden)
        % Define the alias for the driver library as a static property
        function lib = lib()
            lib = 'sc5511a';
        end
        
        function LoadDriver()
        % Load the drive library if necessary
        % The .dll, .h and sc5511a.m files are in ..\drivers\SignalCore_driver
        % And added to path in ..\setpath.m
            if ~libisloaded(SignalCoreSC5511A.lib)
                warning('off');
                switch computer()
                    % The driver supports 32 or 64 bit Windows system
                    case 'PCWIN64'
                        loadlibrary('sc5511a64.dll', 'sc5511a.h', ...
                                    'addheader', 'libusb', ...
                                    'alias', SignalCoreSC5511A.lib);
                        warning('on');
                    case 'PCWIN'
                        loadlibrary('sc5511a32.dll', @sc5511a, ...
                                    'alias', SignalCoreSC5511A.lib);
                        warning('on');
                    otherwise
                        warning('on');
                        error('Your platform is not supported')
                end
            end
        end
        
        function UnloadDriver()
            % Unload the driver library
            if libisloaded(SignalCoreSC5511A.lib)
                unloadlibrary(SignalCoreSC5511A.lib);
            end
        end
    end
end