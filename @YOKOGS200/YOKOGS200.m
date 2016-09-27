classdef YOKOGS200 < GPIBINSTR
% Contains paramaters and methods for YOKOGAWA GS200 voltage source
    properties
        rampstep = 0.002; % increment step when setting voltage/current
        rampinterval = 0.01; % dwell time for each voltage step
        voltage;
        current;
    end
    methods
        function yoko = YOKOGS200(address)
            yoko = yoko@GPIBINSTR(address);
        end
        function set.voltage(yoko, voltage)
            SetVoltage(yoko, voltage);
        end
        function voltage = get.voltage(yoko)
            voltage = GetVoltage(yoko);
        end
        function set.current(yoko, current)
            SetCurrent(yoko, current);
        end
        function current = get.current(yoko)
            current = GetCurrent(yoko);
        end
        % Declaration of all other methods
        % Each method is defined in a separate file
        SetVoltage(yoko, voltage); % Set voltage
        voltage = GetVoltage(yoko); % Get voltage
        SetCurrent(yoko, current); % Set current
        current = GetCurrent(yoko); % Get current
        PowerOn(yoko); % Turn on output
        PowerOff(yoko); % Turn off output
        ShowError(yoko); % Display and clear error
    end
end