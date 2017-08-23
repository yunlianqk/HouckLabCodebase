<<<<<<< HEAD
function [ CH_params ] = SetupCH_Params_Blockade_Truncate( sampInterval, Int_Freq, numPoints, numSegments, phase)
% Precalculate vectors and values for computerized homodyne correlation
% meas.
CH_params.sampInterval = sampInterval;
CH_params.Int_Freq = Int_Freq;
CH_params.tot_length = numPoints;

truncPoints = floor(sampInterval*(numPoints-1)*Int_Freq)/(sampInterval*Int_Freq)+1;
CH_params.truncPoints=truncPoints;
 
CH_params.numSegments = numSegments;
% CH_params.NumPeriodsPerPoint = CH_params.sampInterval*CH_params.Int_Freq;
% CH_params.NumPointsPerPeriod = (1/CH_params.NumPeriodsPerPoint);
% CH_params.NumPeriodsInSignal = floor(CH_params.NumPeriodsPerPoint*(CH_params.tot_length-1))-1;
% 

CH_params.TimeVector = linspace(0, (truncPoints-1)*sampInterval, truncPoints);
CH_params.SineVector = ones(CH_params.numSegments,1)*sin(2*pi*CH_params.Int_Freq*CH_params.TimeVector+phase);
CH_params.CosineVector = ones(CH_params.numSegments,1)*cos(2*pi*CH_params.Int_Freq*CH_params.TimeVector+phase);
end

=======
function [ CH_params ] = SetupCH_Params_Blockade_Truncate( sampInterval, Int_Freq, numPoints, numSegments, phase)
% Precalculate vectors and values for computerized homodyne correlation
% meas.
CH_params.sampInterval = sampInterval;
CH_params.Int_Freq = Int_Freq;
CH_params.tot_length = numPoints;

truncPoints = floor(sampInterval*(numPoints-1)*Int_Freq)/(sampInterval*Int_Freq)+1;
CH_params.truncPoints=truncPoints;
 
CH_params.numSegments = numSegments;
% CH_params.NumPeriodsPerPoint = CH_params.sampInterval*CH_params.Int_Freq;
% CH_params.NumPointsPerPeriod = (1/CH_params.NumPeriodsPerPoint);
% CH_params.NumPeriodsInSignal = floor(CH_params.NumPeriodsPerPoint*(CH_params.tot_length-1))-1;
% 

CH_params.TimeVector = linspace(0, (truncPoints-1)*sampInterval, truncPoints);
CH_params.SineVector = ones(CH_params.numSegments,1)*sin(2*pi*CH_params.Int_Freq*CH_params.TimeVector+phase);
CH_params.CosineVector = ones(CH_params.numSegments,1)*cos(2*pi*CH_params.Int_Freq*CH_params.TimeVector+phase);
end

>>>>>>> fcfd5e9cf561fc8f7ca51bf628e9d0c6f4f94fdd
