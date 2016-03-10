classdef YOKO7621 < GPIBINSTR
% Contains paramaters and methods for YOKOGAWA GS200 voltage source

    properties (Access = public)
        rampstep = 0.002;   % increment step when setting voltage
        rampinterval = 0.01;    % dwell time for each voltage step
    end
    
    properties (Dependent)
        voltage;
    end
    methods
        function yoko = YOKO7621(address)
            yoko = yoko@GPIBINSTR(address);
        end
        function Finalize(yoko)
            Finalize@GPIBINSTR(yoko);
        end
        function set.voltage(yoko, voltage)
            SetVoltage(yoko, voltage);
        end
        function voltage = get.voltage(yoko)
            voltage = GetVoltage(yoko);
        end
        % Declaration of all other methods
        % Each method is defined in a separate file
        voltage = GetVoltage(yoko); % Get voltage
        SetVoltage(yoko, voltage); % Set voltage
        PowerOn(yoko); % Turn on output
        PowerOff(yoko); % Turn off output
    end
end