function averageCount = GetAverageCount(pxa)
% Get number of averages
    fprintf(pxa.instrhandle, ':AVER:Count?');
    averageCount = fscanf(pxa.instrhandle, '%f');
end