function TrigHold(pnax)
% Set trigger to hold
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:MODE HOLD', pnax.GetActiveChannel());
end