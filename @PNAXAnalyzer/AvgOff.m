function AvgOff(pnax)
% Turn off average
    fprintf(pnax.instrhandle, 'SENSe%d:AVERage OFF', pnax.GetActiveChannel());
end