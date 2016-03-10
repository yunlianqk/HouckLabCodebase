function AvgOn(pnax)
% Turn on average
    fprintf(pnax.instrhandle, 'SENSe%d:AVERage ON', pnax.GetActiveChannel());
end