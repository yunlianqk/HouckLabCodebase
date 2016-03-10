function measname = MeasName(~, channel, trace, meastype)
% Generate name for a measurement
    measname = sprintf('CH%d_%s_%d', channel, meastype, trace);
end