function SetAverageCount(pxa,averageCount)
% Set number of averages
    fprintf(pxa.instrhandle, [':AVER:Count ' num2str(averageCount)]);
end