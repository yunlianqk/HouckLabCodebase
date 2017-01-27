function numPoints = GetNumPoints(pxa)
% Get start frequency
    fprintf(pxa.instrhandle, ':SWEEP:POINTS?');
    numPoints = fscanf(pxa.instrhandle, '%f');
end