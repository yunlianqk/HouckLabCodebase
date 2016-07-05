function Reset(pnax)
% Reset to default configuration
    for channel = pnax.GetChannelList()
        pnax.DeleteChannel(channel);
    end
    
    % Channel 1, trace 1 for trans amp
    transCh1 = TRANSParams();
    transCh1.channel = 1;
    transCh1.trace = 1;
    transCh1.format = 'MLOG';
    pnax.SetParams(transCh1);
    % Channel 1, trace 2 for trans phase
    transCh1.trace = 2;
    transCh1.format = 'UPH';
    pnax.SetParams(transCh1);
    pnax.AvgOn();
    pnax.TrigContinuous();
    pause(0.5);
    
    % Channel 2, trace 3 for spec amp
    specCh2 = SPECParams();
    specCh2.channel = 2;
    specCh2.trace = 3;
    specCh2.format = 'MLOG';
    pnax.SetParams(specCh2);
    % Channel 2, trace 4 for spec phase
    specCh2.trace = 4;
    specCh2.format = 'UPH';
    pnax.SetParams(specCh2);
    pnax.AvgOn();
    pnax.TrigContinuous();
    pause(0.5);
    
    pnax.TrigHoldAll();
    pnax.AutoScaleAll();
end