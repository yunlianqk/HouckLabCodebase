function TrigSingle(pnax)
% Set trigger to single
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:MODE SiNGle', pnax.GetActiveChannel());
end