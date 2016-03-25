function AvgClear(pnax)
% Clear average
    fprintf(pnax.instrhandle, 'SENSe%d:AVERage:CLEar', pnax.GetActiveChannel());
end