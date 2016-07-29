function params = GetParams(self)
% Get card parameters
    params = paramlib.acqiris();
    
    [~, params.fullscale, params.offset, Vertcouling, ~] = AqD1_getVertical(self.instrID, 1);
    if Vertcouling == 4
        params.couplemode = 'AC';
    else
        params.couplemode = 'DC';
    end
    [~, params.sampleinterval, ~] = AqD1_getHorizontal(self.instrID);
    [~, StartDelay] = AqD1_getAvgConfigInt32(self.instrID, 1, 'StartDelay');
    params.delaytime = double(StartDelay)*params.sampleinterval;
    [~, params.samples] = AqD1_getAvgConfigInt32(self.instrID, 1, 'NbrSamples');
    params.samples = double(params.samples);
    [~, NbrRoundRobins] = AqD1_getAvgConfigInt32(self.instrID, 1, 'NbrRoundRobins');
    params.averages = double(NbrRoundRobins)*self.AqReadParameters.softAvg;
    [~, params.segments] = AqD1_getAvgConfigInt32(self.instrID, 1, 'NbrSegments');
    params.segments = double(params.segments);
    [~, ~, trigPattern, ~, ~, ~, ~] = AqD1_getTrigClass(self.instrID);
    switch double(trigPattern)
        case 1
            params.trigSource = 'Channel1';
            trigCh = 1;
        case 2
            params.trigSource = 'Channel2';
            trigCh = 2;
        case -hex2dec('80000000')
            params.trigSource = 'External1';
            trigCh = -1;
        otherwise
    end
    [~, ~, ~, trigLevel, ~] = AqD1_getTrigSource(self.instrID, trigCh);
    if trigCh < 0
        params.trigLevel = double(trigLevel) / 1000;
    else
        params.trigLevel = double(trigLevel) / 100;
    end
    params.trigPeriod = self.AqReadParameters.trigPeriod;
end