%% Initialize
fclose(instrfind)
delete(instrfind)


%% Single Ramp Up Measurement
initialize_k2400;
Istart=1E-6;
Istop=2E-6;
Istep=0.02E-6;
CurrentSweep_k2400(Istart,Istop,Istep,k2400);
% Fetch IV data
[Ifw,Vfw]=FetchCurrentSweep_k2400(Istart,Istop,Istep,k2400);
Rfw=Vfw./Ifw;
Rfw_avg = mean(Rfw);
% Plot I-V curve
figure()
subplot(2,1,1)
plot(Ifw,Vfw,'o',...
          'MarkerEdgeColor','k',...
          'MarkerFaceColor','r',...
          'MarkerSize',5);
xlabel('Source-current (A)'),ylabel('Measured-volts(V)')
str=sprintf('Current Sweep %.2f uA - %.2f uA',Istart/1E-6,Istop/1E-6);
title(str);
subplot(2,1,2)
plot(Ifw,Rfw,'o',...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','r',...
    'MarkerSize',5);
xlabel('Source-current (A)'),ylabel('Resistance (Ohms)')
hold on;
plot([Ifw(0) Ifw(end)],[Rfw_avg Rfw_avg],'k.')
hold off;
str=sprintf('Average Resistance %.2f ohms',Rfw_avg);
% Clear buffer
clearBuffer_k2400;
% Reset
reset_k2400;
