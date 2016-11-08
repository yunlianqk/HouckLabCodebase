function SetCurrent(yoko, current)
% Set current
    start = yoko.GetCurrent();
    stop = current;
    steps = round(abs(stop - start)/yoko.rampstep);
	yoko.PowerOn();
    for tempcurrent = linspace(start, stop, steps)
        fprintf(yoko.instrhandle, 'SA%f;E;', tempcurrent);
        pause(yoko.rampinterval);
    end
end