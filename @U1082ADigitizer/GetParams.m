function params = GetParams(card)
% Get card parameters
    params = ACQIRISParams();
    
    [~, params.fullscale, ~, Vertcouling, ~] = AqD1_getVertical(card.instrID, 1);
    if Vertcouling == 4
        params.couplemode = 'AC';
    else
        params.couplemode = 'DC';
    end
    [~, params.sampleinterval, ~] = AqD1_getHorizontal(card.instrID);
    [~, StartDelay] = AqD1_getAvgConfigInt32(card.instrID, 1, 'StartDelay');
    params.delaytime = double(StartDelay)*params.sampleinterval;
    [~, params.samples] = AqD1_getAvgConfigInt32(card.instrID, 1, 'NbrSamples');
    params.samples = double(params.samples);
    [~, params.averages] = AqD1_getAvgConfigInt32(card.instrID, 1, 'NbrWaveforms');
    params.averages = double(params.averages);
    [~, params.segments] = AqD1_getAvgConfigInt32(card.instrID, 1, 'NbrSegments');
    params.segments = double(params.segments);
end