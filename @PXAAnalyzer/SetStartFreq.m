function SetStartFreq(pxa, start)
% Set frequency
    fprintf(pxa.instrhandle, ['freq:start ' num2str(start) 'HZ']);
end