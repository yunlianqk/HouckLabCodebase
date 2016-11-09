function SetStopFreq(pxa, stop)
% Set frequency
    fprintf(pxa.instrhandle, ['freq:stop ' num2str(stop) 'HZ']);
end