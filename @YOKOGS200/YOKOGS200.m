classdef YOKOGS200 < GPIBINSTR
% Contains paramaters and methods for YOKOGAWA GS200 voltage source
    properties
        rampstep = 0.002; % increment step when setting voltage/current
        rampinterval = 0.01; % dwell time for each voltage step
        voltage;
        current;
        mode;
        output;
    end
    methods
        function yoko = YOKOGS200(address)
            yoko = yoko@GPIBINSTR(address);
        end
        function set.voltage(yoko, voltage)
            SetVoltage(yoko, voltage);
        end
        function voltage = get.voltage(yoko)
            if strcmp(yoko.GetMode(), 'voltage')
                voltage = GetVoltage(yoko);
            else
                voltage = [];
            end
        end
        function set.current(yoko, current)
            SetCurrent(yoko, current);            
        end
        function current = get.current(yoko)
            if strcmp(yoko.GetMode(), 'current')
                current = GetCurrent(yoko);
            else
                current = [];
            end
        end
        function set.mode(yoko, mode)
            SetMode(yoko, mode);
        end
        function mode = get.mode(yoko)
            mode = GetMode(yoko);
        end
        function set.output(yoko, output)
            if output
                yoko.PowerOn();
            else
                yoko.PowerOff();
            end
        end
        function output = get.output(yoko)
            fprintf(yoko.instrhandle, 'OUTPut?');
            output = fscanf(yoko.instrhandle, '%d');
        end
        % Declaration of all other methods
        % Each method is defined in a separate file
        SetVoltage(yoko, voltage); % Set voltage
        voltage = GetVoltage(yoko); % Get voltage
        SetCurrent(yoko, current); % Set current
        current = GetCurrent(yoko); % Get current
        SetMode(yoko, mode); % Set mode
		mode = GetMode(yoko); % Get mode
        PowerOn(yoko); % Turn on output
        PowerOff(yoko); % Turn off output
        ShowError(yoko); % Display and clear error
    end
end