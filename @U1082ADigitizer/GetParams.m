function params = GetParams(self)
% Get card parameters
    params = paramlib.acqiris();
    
    [~, params.fullscale, ~, Vertcouling, ~] = AqD1_getVertical(self.instrID, 1);
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
    params.timeout = self.AqReadParameters.timeOut;
end