function TrigContinous(pnax)
% Set trigger to continous
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:MODE CONTinuous', pnax.GetActiveChannel());
end