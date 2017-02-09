function [amplitude, phase] = Demodulate(sampInterval, data, intFreq)
% Demodulate an array of data with intermediate frequency
% Input: data should be an M*N array,
%        where each 1*N row vector is a single data
%        sampInterval is in seconds
%        intFreq is in Hz
% Return: amplitude and phase are both 1*M row vector
%         each element is the demodulated amp/phase of the corresponding trace
    
    totLength = size(data, 2);
    if intFreq == 0
        truncPoints = totLength;
    else
    % Truncate the dataset such that the remainder contains an integer number of periods
        truncPoints = floor((sampInterval*(totLength-1)*intFreq)/(sampInterval*intFreq))+1;
    end
    data = data(:, 1:truncPoints);
    timeVector = linspace(0, (truncPoints-1)*sampInterval, truncPoints);
    sineVector = sin(2*pi*intFreq*timeVector);
    cosineVector = cos(2*pi*intFreq*timeVector);
    
    iq = (2*cosineVector*data'+2i*sineVector*data')/truncPoints;
    amplitude = abs(iq);
    phase = angle(iq);
end