function params = GetParams(card)
% Get card parameters
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
    [~, params.averages] = AqD1_getAvgConfigInt32(card.instrID, 1, 'NbrWaveforms');
    [~, params.segments] = AqD1_getAvgConfigInt32(card.instrID, 1, 'NbrSegments');
end