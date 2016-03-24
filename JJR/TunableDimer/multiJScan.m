%% mulitple j values scan
% here we're going to watch transmission as the right qubit moves through
% resonance for several different J values.
%% set up scan trajectories
% outter loop
% couplerFluxStart=-.2;
% couplerFluxStop =0;
% couplerFluxSteps = 3;
% inner loop 
% qubitFluxStart=-.55;
% qubitFluxStop=-.05;
% qubitFluxSteps = 10;


% outter loop
couplerFluxStart=-.06;
couplerFluxStop =-.2;
couplerFluxSteps = 36;
% inner loop 
qubitFluxStart=-.4;
qubitFluxStop=-.2;
qubitFluxSteps = 51;


couplerFluxVector=linspace(couplerFluxStart,couplerFluxStop,couplerFluxSteps);
%% visualize trajectories
figure(); hold on
for index=1:couplerFluxSteps
    currentCouplerFlux=couplerFluxVector(index);
    startFlux = [0 qubitFluxStart currentCouplerFlux];
    stopFlux = [0 qubitFluxStop currentCouplerFlux];
    startVoltage=fc.calculateVoltagePoint(startFlux);
    stopVoltage=fc.calculateVoltagePoint(stopFlux);
    vtraj=fc.generateTrajectory(startVoltage,stopVoltage,qubitFluxSteps);
    ftraj=fc.calculateFluxTrajectory(vtraj);
%     scatter3(vtraj(1,:),vtraj(2,:),vtraj(3,:));
    scatter3(ftraj(1,:),ftraj(2,:),ftraj(3,:));
    xlabel('left qubit flux');ylabel('right qubit flux');zlabel('coupler flux')
end
hold off
%% set up data structures and run scan

clear multiJScanS21A multiJScanS21P multiJScanS41A multiJScanS41P
points=pnax.transparams.points;freqvector=pnax.GetAxis();
multiJScanS21A=zeros(qubitFluxSteps,points);
multiJScanS21P=zeros(qubitFluxSteps,points);
multiJScanS41A=zeros(qubitFluxSteps,points);
multiJScanS41P=zeros(qubitFluxSteps,points);

for index=1:couplerFluxSteps
    time=fix(clock);
    currentCouplerFlux=couplerFluxVector(index);
    startFlux = [0 qubitFluxStart curr  entCouplerFlux];
    stopFlux = [0 qubitFluxStop currentCouplerFlux];
    startVoltage=fc.calculateVoltagePoint(startFlux);
    stopVoltage=fc.calculateVoltagePoint(stopFlux);
    vtraj=fc.generateTrajectory(startVoltage,stopVoltage,qubitFluxSteps);
    ftraj=fc.calculateFluxTrajectory(vtraj);
    figure(65)
    scatter3(ftraj(1,:),ftraj(2,:),ftraj(3,:));
    xlabel('left qubit flux');ylabel('right qubit flux');zlabel('coupler flux')
    for index2=1:qubitFluxSteps
        % update flux/voltage
        fc.currentVoltage=vtraj(:,index2);
        [transamp, transph, S41transamp, S41transph] = pnax.FastReadS21andS41Trans(transWaitTime);
        multiJScanS21A(index2,:)=transamp;
        multiJScanS21P(index2,:)=transph;
        multiJScanS41A(index2,:)=S41transamp;
        multiJScanS41P(index2,:)=S41transph;
        
        % display
        figure(158);subplot(1,2,1);
        imagesc(freqvector/1e9,[1,index2],multiJScanS21A(1:index2,:)); title(['multiJScan' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('Through Measurement');
        subplot(1,2,2);
        imagesc(freqvector/1e9,[1,index2],multiJScanS41A(1:index2,:)); title(['Scan ' num2str(index) 'of ' num2str(couplerFluxSteps)]); ylabel('step');xlabel('Cross Measurement');
    end
    save(['multiJScan' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'CM','f0','fc','transWaitTime','transparams','S41transparams','freqvector','couplerFluxVector','qubitFluxStart',...
        'qubitFluxStop','qubitFluxSteps','points','multiJScanS21A','multiJScanS21P','multiJScanS41A','multiJScanS41P');
end
figure();




