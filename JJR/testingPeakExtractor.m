%% script for fitting coupler using the peakExtractor function I wrote
%JJR - 8/2/16

%% 
addpath('C:\Users\James\Documents\GitHub\HouckLabMeasurementCode\JJR')
%%
data = d2;

%%

[ xInd, yInd, peakVals ] = peakExtractor( data, 1,1);
figure();
plot(xInd,yInd,'.')


%% get data from latest flux offset

load('Z:\James\SteadyStateDimer\CouplerFit\transAlongTrajectory201681191924.mat')
oldFluxAxis = ftraj(3,:);
freqAxis = linspace(pnaxSettings.start,pnaxSettings.stop,pnaxSettings.points);
data = transS41AlongTrajectoryAmp;
clearvars -except oldFluxAxis freqAxis data
%%
figure();
imagesc(freqAxis , oldFluxAxis , data)

%%  extract peaks
[ xInd, yInd, peakVals ] = peakExtractor( data, 1,0);
figure();
plot(xInd,yInd)
plot(oldFluxAxis,freqAxis([yInd]))

%% 
cftool(xInd, yInd)
