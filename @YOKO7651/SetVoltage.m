function SetVoltage(yoko, voltage)
% Set voltage
    yoko.PowerOn();
    start = yoko.GetVoltage();
    stop = voltage;
    steps = round(abs(stop - start)/yoko.rampstep);
    for tempvolt = linspace(start, stop, steps)
        fprintf(yoko.instrhandle, 'S%f;E;', tempvolt);
        pause(yoko.rampinterval);
    end
end