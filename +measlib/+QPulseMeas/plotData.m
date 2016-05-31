function plotData(data)
% Plot raw and integrate data

% Input argument can be either a measlib.QLifeTime.Data object
% or a struct that is converted from such object

    if isempty(data.tRange)
        data.tRange = [data.tAxis(1), data.tAxis(end)];
    end
    [intdataI, intdataQ] = measlib.QPulseMeas.integrateData(data);
    tAxis = data.tAxis/1e-6;
    tRange = data.tRange/1e-6;

    figure;
    % Plot raw data
    subplot(2,2,1);
    imagesc(tAxis, 1:length(data.dataAxis), data.rawdataI);
    hold on;
    plot([tRange(1), tRange(1)], [1, length(data.dataAxis)], ...
         '--r', 'LineWidth', 2);
    plot([tRange(2), tRange(2)], [1, length(data.dataAxis)], ...
         '--r', 'LineWidth', 2);
    hold off;
    ylabel('# of experiment');
    title('Raw data I');
    subplot(2,2,3);
    imagesc(tAxis, 1:length(data.dataAxis), data.rawdataQ);
    hold on;
    plot([tRange(1), tRange(1)], [1, length(data.dataAxis)], ...
         '--r', 'LineWidth', 2);
    plot([tRange(2), tRange(2)], [1, length(data.dataAxis)], ...
         '--r', 'LineWidth', 2);
    hold off;
    xlabel('Time (\mus)');
    ylabel('# of experiment');
    title('Raw data Q');
    % Plot integrated data
    subplot(2,2,2);
    plot(1:length(data.dataAxis), intdataI);
    ylabel('V_I (V)');
    title('Integrated data I');
    subplot(2,2,4);
    plot(1:length(data.dataAxis), intdataQ);
    xlabel('# of experiment');
    ylabel('V_Q (V)');
    title('Integrated data Q');
end