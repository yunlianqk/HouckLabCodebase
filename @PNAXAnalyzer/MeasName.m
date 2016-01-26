function measname = MeasName(~, channel, trace)
% Generate name for a measurement
    measname = ['CH', num2str(channel), '_TR', num2str(trace)];
end