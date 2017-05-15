function [demodI, demodQ] = Demodulate(sampInterval, data, intFreq)
% Demodulate an array of data with intermediate frequency
% Input: data should be an M*N array,
%        where each 1*N row vector is a single data trace
%        sampInterval is in seconds
%        intFreq is in Hz
% Return: intI and intQ are both 1*M row vector
%         each element is the demodulated I/Q of the corresponding trace
    
    totLength = size(data, 2);
    if intFreq == 0
        truncPoints = totLength;
    else
    % Truncate the dataset such that the remainder contains an integer number of periods
        truncPoints = floor((sampInterval*(totLength-1)*intFreq)/(sampInterval*intFreq))+1;
    end
    data = data(:, 1:truncPoints);
    t = linspace(0, (truncPoints-1)*sampInterval, truncPoints);
    demodI = cos(2*pi*intFreq*t)*data'/truncPoints;
    demodQ = sin(2*pi*intFreq*t)*data'/truncPoints;
end