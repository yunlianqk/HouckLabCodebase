function [intdataI, intdataQ] = integrateData(data)
% Integrate data

% Input can be either a measlib.QLifeTime.Data object
% or a struct that is converted from such object
% Output are the demodulated and integrated data

    if isempty(data.tRange)
        data.tRange = [data.tAxis(1), data.tAxis(end)];
    end
    subdomain = find(data.tAxis >= data.tRange(1), 1) ...
                :find(data.tAxis >= data.tRange(2), 1);
    dt = data.tAxis(2) - data.tAxis(1);
    % Software heterodyne demodulation
    intdataI = funclib.Demodulate(dt, data.rawdataI(:, subdomain), data.intFreq);
    intdataQ = funclib.Demodulate(dt, data.rawdataQ(:, subdomain), data.intFreq);
end