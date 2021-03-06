function SetVoltage(yoko, voltage)
% Set voltage
    start = yoko.GetVoltage();
    stop = voltage;
    steps = round(abs(stop - start)/yoko.rampstep);
	yoko.PowerOn();
    for tempvolt = linspace(start, stop, steps)
        fprintf(yoko.instrhandle, 'S%f;E;', tempvolt);
        pause(yoko.rampinterval);
    end
end