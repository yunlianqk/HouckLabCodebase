function result = fitData(data)
% Fit the data for qubit lifetime measurements

% Input argument can be either a measlib.QLifeTime.Data object
% or a struct that is converted from such object

    if isempty(data.tRange)
        data.tRange = [data.tAxis(1), data.tAxis(end)];
    end
    [data.intdataI, data.intdataQ] = measlib.QPulseMeas.integrateData(data);
    tAxis = data.tAxis/1e-6;
    tRange = data.tRange/1e-6;
    figure;
    ax1 = subplot(2,2,2);
    ax2 = subplot(2,2,4);

    switch data.meastype
        % Fit the data according to the measurement type
        case 'Rabi'
            dataAxis = data.dataAxis;
            textAxis = 'Rabi amplitude';
            resultI = funclib.RabiFit(dataAxis, data.intdataI, ax1)*2;
            resultQ = funclib.RabiFit(dataAxis, data.intdataQ, ax2)*2;
            textI = sprintf('\\theta_{0.5} = %.3f \\pi', resultI/pi);
            textQ = sprintf('\\theta_{0.5} = %.3f \\pi', resultQ/pi);
        case 'T1'
            dataAxis = data.dataAxis/1e-6;
            textAxis = 'Delay (\mus)';
            resultI = funclib.ExpFit(dataAxis, data.intdataI, ax1);
            resultQ = funclib.ExpFit(dataAxis, data.intdataQ, ax2);
            textI = sprintf('T_1 = %.2f \\mus', resultI);
            textQ = sprintf('T_1 = %.2f \\mus', resultQ);
        case 'Ramsey'
            dataAxis = data.dataAxis/1e-6;
            textAxis = 'Delay (\mus)';
            resultI = funclib.ExpCosFit(dataAxis, data.intdataI, ax1);
            resultQ = funclib.ExpCosFit(dataAxis, data.intdataQ, ax2);
            textI = sprintf('T_2^* = %.2f \\mus', resultI);
            textQ = sprintf('T_2^* = %.2f \\mus', resultQ);
        case 'Echo'
            dataAxis = data.dataAxis/1e-6;
            textAxis = 'Delay (\mus)';
            resultI = funclib.ExpCosFit(dataAxis, data.intdataI, ax1);
            resultQ = funclib.ExpCosFit(dataAxis, data.intdataQ, ax2);
            textI = sprintf('T_2^E = %.2f \\mus', resultI);
            textQ = sprintf('T_2^E = %.2f \\mus', resultQ);
        otherwise
            error('Unknown measurement type');
    end
    
    % Plot raw, integrated and fitted data
    subplot(2,2,1);
    imagesc(tAxis, dataAxis, data.rawdataI);
    hold on;
    plot([tRange(1), tRange(1)], [dataAxis(1), dataAxis(end)], ...
         '--r', 'LineWidth', 2);
    plot([tRange(2), tRange(2)], [data.dataAxis(1), data.dataAxis(end)], ...
         '--r', 'LineWidth', 2);
    hold off;
    ylabel(textAxis);
    title('Raw data I');
    subplot(2,2,3);
    imagesc(tAxis, dataAxis, data.rawdataQ);
    hold on;
    plot([tRange(1), tRange(1)], [dataAxis(1), dataAxis(end)], ...
         '--r', 'LineWidth', 2);
    plot([tRange(2), tRange(2)], [dataAxis(1), dataAxis(end)], ...
         '--r', 'LineWidth', 2);
    hold off;
    xlabel('Time (\mus)');
    ylabel(textAxis);
    title('Raw data Q');
    
    subplot(2,2,2);
    ylabel('V_I (V)');
    title('Integrated data I');
    text(0.1, 0.9, textI, 'Units', 'normalized', 'FontSize', 16);
    subplot(2,2,4);
    xlabel(textAxis);
    ylabel('V_Q (V)');
    title('Integrated data Q');
    text(0.1, 0.9, textQ, 'Units', 'normalized', 'FontSize', 16);

    result = mean([resultI, resultQ]);
end