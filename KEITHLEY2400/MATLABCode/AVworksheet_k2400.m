%%
fclose(instrfind)
delete(instrfind)
%% Initialize
initialize_k2400;
%% Perform FORWARD current sweep
Istart=0.01E-6;
Istop=2.01E-6;
Istep=0.05E-6;
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
Ravgfw=mean(Vfw./Ifw);
message=['Average forward resistance: ',num2str(Ravgfw)]; disp(message)
% plot average resistance line
plot(Ifw,Ravgfw*Ifw,'--k')
%% Clear buffer
clearBuffer_k2400;
%% Reset
reset_k2400;
%% Initialize
initialize_k2400;
%% Perform REVERSE current sweep
Istart=4E-6;
Istop=0.5E-6;
Istep=-0.05E-6;
CurrentSweep_k2400(Istart,Istop,Istep,k2400);
%% Fetch IV data
[Irev,Vrev]=FetchCurrentSweep_k2400(Istart,Istop,Istep,k2400);
% Plot I-V curve
plot(Irev,Vrev,'o',...
          'MarkerEdgeColor','k',...
          'MarkerFaceColor','b',...
          'MarkerSize',5);
%legend('forward','reverse','Location','northwest')
%average resistance
Ravgrev=mean(Vrev./Irev);
message=['Average reverse resistance: ',num2str(Ravgrev)]; disp(message)
% plot average resistance line
plot(Irev,Ravgrev*Irev,'--k')
%% Clear buffer
clearBuffer_k2400;
%% Reset
reset_k2400;