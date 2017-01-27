function SetNumPoints(pxa,numPoints)
% Set numPoints
    fprintf(pxa.instrhandle, [':SWEEP:POINTS ' num2str(numPoints)]);
end