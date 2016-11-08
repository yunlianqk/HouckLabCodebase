%% 2-Point Resistance Measurement Worksheet
% A simple sweep of current to measure resistance in a 2-point
% configuration.  
% Works with the Keithley 2400 SourceMeter
 
%% In case something goes wrong
fclose(instrfind)
delete(instrfind)

%% Settings
% sweep settings
Istart=.1E-6;
Istop=7E-6;
numSteps=51; % increasing this number might throw an error
Istep=(Istop-Istart)/numSteps;

groupData.Iraw = [];
groupData.Vraw = [];
groupData.Rraw = [];
groupData.R = [];   % single resistance value for each measurment

%% run a scan, plot, and append new measurement to group
tic;
initialize_k2400;
CurrentSweep_k2400_4pt(Istart,Istop,Istep,k2400);

% Fetch IV data
[I,V]=FetchCurrentSweep_k2400(Istart,Istop,Istep,k2400);
R=V./I;
R_avg = mean(R);
R_end = R(end);

% Store Data
groupData.Iraw = [groupData.Iraw I];
groupData.Vraw = [groupData.Vraw V];
groupData.Rraw = [groupData.Rraw R];
groupData.R = [groupData.R R_avg];
% groupData.R = [groupData.R R_end];    

% Make Plots
figure(123)
subplot(3,1,1)
plot(groupData.R,'o',...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','r',...
    'MarkerSize',5);
xlabel('Source-current (A)'),ylabel('Resistance (Ohms)')
subplot(3,1,2)
plot(I,V,'o',...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','r',...
    'MarkerSize',5);
xlabel('Source-current (A)'),ylabel('Measured-volts(V)')
str=sprintf('Current Sweep %.2f uA - %.2f uA',Istart/1E-6,Istop/1E-6);
title(str);
subplot(3,1,3)
plot(I,R,'o',...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','r',...
    'MarkerSize',5);
xlabel('Source-current (A)'),ylabel('Resistance (Ohms)')
hold on;
plot([I(1) I(end)],[R_avg R_avg],'k')
plot([I(1) I(end)],[R_end R_end],'k')
hold off;
str=sprintf('Average Resistance %.2f ohms, End Resistance of %.2f ohms',R_avg, R_end);
title(str)

% Clear buffer
clearBuffer_k2400;
% Reset
reset_k2400;
toc
