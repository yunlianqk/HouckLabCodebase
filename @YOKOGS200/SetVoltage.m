function SetVoltage(yoko, varargin)
% Set voltage
if isempty(varargin)
    setvoltage = yoko.voltage;
else
    setvoltage = varargin{1};
end
    yoko.PowerOn();
    yoko.GetVoltage();
    steps = round(abs(setvoltage - yoko.voltage)/yoko.rampstep);
    for tempvolt = linspace(yoko.voltage, setvoltage, steps)
        fprintf(yoko.instrhandle, ['S', num2str(tempvolt), ';E;']);
        pause(yoko.rampinterval);
    end
    yoko.voltage = setvoltage;

end