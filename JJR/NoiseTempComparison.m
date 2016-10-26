%% loop to compare tempNoise vs incomingNoise and use larger for down fridge calculations
clear,clc
% attenDB = [7.79 11 7.57 8.46 11.6]' %optimal
% attenDB = [10 20 10 1 20]'  % current
% attenDB = [6 10 10 1 20]'   
attenDB = [6 10 10 1 19]'   

plateNames = {'50 K'; '4 K'; 'Still'; 'Quasi-Cold'; 'Base'};
plateTemps = [50 4 .700 .100 .007]';
attenLin = 10.^(attenDB/10);

incomingNoise = 300;
for ind=1:length(plateTemps)
    tempNoise = plateTemps(ind);
    attenuatedIncomingNoise = incomingNoise./attenLin(ind);
    attenuatedIncomingNoiseStore(ind)= attenuatedIncomingNoise;
    if attenuatedIncomingNoise > tempNoise
        outgoingNoise(ind)=attenuatedIncomingNoise;
    else
        outgoingNoise(ind)=tempNoise;
    end
    incomingNoise = outgoingNoise(ind);
end
attenuatedIncomingNoiseStore = attenuatedIncomingNoiseStore';
outgoingNoise = outgoingNoise';
table(attenDB,plateTemps,outgoingNoise,attenuatedIncomingNoiseStore,'RowNames',plateNames)
if outgoingNoise(end) > .007
    display('NOT IDEAL')
else
    display('NICE')
end
