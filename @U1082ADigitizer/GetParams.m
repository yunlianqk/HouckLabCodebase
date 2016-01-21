function GetParams(card)
% Get card parameters
    [~, card.fullscale, ~, Vertcouling, ~] = AqD1_getVertical(card.instrID, 1);
    if Vertcouling == 4
        card.couplemode = 'AC';
    else
        card.couplemode = 'DC';
    end
    [~, card.sampleinterval, ~] = AqD1_getHorizontal(card.instrID);
    [~, StartDelay] = AqD1_getAvgConfigInt32(card.instrID, 1, 'StartDelay');
    card.delaytime = double(StartDelay)*card.sampleinterval;
    [~, card.samples] = AqD1_getAvgConfigInt32(card.instrID, 1, 'NbrSamples');
    [~, card.averages] = AqD1_getAvgConfigInt32(card.instrID, 1, 'NbrWaveforms');
    [~, card.segments] = AqD1_getAvgConfigInt32(card.instrID, 1, 'NbrSegments');
end