function TrigHoldAll(pnax)
% Hold the trigger for ALL channels
    fprintf(pnax.instrhandle, 'SYSTem:CHANnels:HOLD');
end