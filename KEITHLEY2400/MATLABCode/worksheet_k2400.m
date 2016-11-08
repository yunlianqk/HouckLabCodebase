%%
fclose(instrfind)
delete(instrfind)
%% Initialize
initialize_k2400;
%% Perform FORWARD current sweep
Istart=1E-6;
Istop=2E-6;
Istep=0.02E-6;
CurrentSweep_k2400(Istart,Istop,Istep,k2400);
%% Fetch IV data
[Ifw,Vfw]=FetchCurrentSweep_k2400(Istart,Istop,Istep,k2400);
% Plot I-V curve
figure()
plot(Ifw,Vfw,'o',...
          'MarkerEdgeColor','k',...
          'MarkerFaceColor','r',...
          'MarkerSize',5);
xlabel('Source-current (A)'),ylabel('Measured-volts(V)')
str=sprintf('Current Sweep %.2f uA - %.2f uA',Istart/1E-6,Istop/1E-6);
title(str);
hold on;
%average resistance
%% Clear buffer
clearBuffer_k2400;
%% Reset
reset_k2400;
%% Initialize
initialize_k2400;
%% Perform REVERSE current sweep
Istart=5E-6;
Istop=1E-6;
Istep=-0.1E-6;
CurrentSweep_k2400(Istart,Istop,Istep,k2400);
%% Fetch IV data
[Irev,Vrev]=FetchCurrentSweep_k2400(Istart,Istop,Istep,k2400);
% Plot I-V curve
plot(Irev,Vrev,'o',...
          'MarkerEdgeColor','k',...
          'MarkerFaceColor','b',...
          'MarkerSize',5);
legend('forward','reverse','Location','northwest')
%% Clear buffer
clearBuffer_k2400;
%% Reset
reset_k2400;