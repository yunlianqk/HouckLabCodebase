function SetCurrent(yoko, current)
% Set current
	start = yoko.GetCurrent();
    stop = current;
    steps = round(abs(stop - start)/yoko.rampstep);
    yoko.PowerOn();
    for tempcurrent = linspace(start, stop, steps)
        fprintf(yoko.instrhandle, ':SOURce:LEVel:AUTO %f', tempcurrent);
        pause(yoko.rampinterval);
    end
end