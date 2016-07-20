classdef YOKO7651 < GPIBINSTR
% Contains paramaters and methods for YOKOGAWA GS200 voltage source

    properties (Access = public)
        rampstep = 0.002;   % increment step when setting voltage
        rampinterval = 0.01;    % dwell time for each voltage step
        voltage;
    end
    methods
        function yoko = YOKO7651(address)
            yoko = yoko@GPIBINSTR(address);
        end
        function set.voltage(yoko, voltage)
            SetVoltage(yoko, voltage);
        end
        function voltage = get.voltage(yoko)
            voltage = GetVoltage(yoko);
        end
        % Declaration of all other methods
        % Each method is defined in a separate file
        SetVoltage(yoko, voltage); % Set voltage
        voltage = GetVoltage(yoko); % Get voltage
        
        PowerOn(yoko); % Turn on output
        PowerOff(yoko); % Turn off output
    end
end
