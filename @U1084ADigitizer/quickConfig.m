function [status customAcqirisParameters] = quickConfig(customAcqirisParameters)
%quickConfig - Call configure_settings_U1084A with custom settings
%
% customAcqirisParameters needs to have the instrumentID set as done by the
% initialize_cardU1084A function.

customAcqirisParameters.fullScale1 = 5;
customAcqirisParameters.samplingInterval = 1*8e-9;
customAcqirisParameters.numSamples = 512*1024;
customAcqirisParameters.numSegments = 1;

customAcqirisParameters.numWaveforms = 1;
customAcqirisParameters.vertCoupling1 = 3;


% One channel mode
customAcqirisParameters.nbrConvertersPerChannel = 2;
customAcqirisParameters.usedChannels = hex2dec('00000001');

% External trigger
customAcqirisParameters.trigLevel=800; 
customAcqirisParameters.trigSource=hex2dec('80000000'); 
customAcqirisParameters.trigChannel=-1; 

customAqReadParameters.blank = 0;

[status acqirisParameters] = configure_settings_U1084A(customAcqirisParameters);

end