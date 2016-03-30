function measname = MeasName(~, channel, trace, meastype)
% Generate name for a measurement

    % Follow the PNAX default naming convention
    % measname = 'CH2_S21_2' means measuring S21 in Channel 2, Trace 2
    measname = sprintf('CH%d_%s_%d', channel, meastype, trace);
end