tic
%% peakFitting
load('Z:\Mattias\Data\tunableDimer\PNAX_Calibrations_091817\matrixCalibration_rightInput_couplerSweep_-50wAtten_20170918_1550.mat')
transUpper=transS21AlongTrajectoryAmp; % same ordering as S21 - left out and left in
transLower=transS41AlongTrajectoryAmp; % same ordering as S21 - left out and left in

%%
fluxStart=-0.5; fluxStop=0.5;
% fluxStart=0.0; fluxStop=1;
fluxVec = linspace(fluxStart,fluxStop,steps);

upperRange = [1215:2200];
% upperRange = 1:length(ftrans);
upperFreqVec=ftrans(upperRange)./1e9;
transUpperCrop=transUpper(:,upperRange)';


lowerRange = [1000:1300];
% lowerRange = 1:length(ftrans);
lowerFreqVec=ftrans(lowerRange)./1e9;
transLowerCrop=transLower(:,lowerRange)';


figure(23);
subplot(2,1,1);
imagesc(fluxVec,1:length(ftrans),transUpperCrop);
set(gca, 'YDir', 'normal');
colormap parula
ylabel('Frequency Index')

subplot(2,1,2);
imagesc(fluxVec,1:length(ftrans),transLowerCrop);
set(gca, 'YDir', 'normal');
colormap parula
ylabel('Frequency Index');

%% pulling out maxes
% ignore SLL data from index 216 up to 233
[upperMaxVals,upperMaxInd]=max(transUpperCrop,[],1);
[LowerMaxVals,lowerMaxInd]=max(transLowerCrop,[],1);
for ind=1:length(upperMaxInd)
    upperMaxFreq(ind)=upperFreqVec(upperMaxInd(ind));
    lowerMaxFreq(ind)=lowerFreqVec(lowerMaxInd(ind));
end


% upperIndexCut=[458:485];
upperIndexCut=[];
newIndicesUpper=setdiff(1:steps,upperIndexCut);
upperFluxVecCrop=fluxVec(newIndicesUpper);
upperMaxFreqCrop=upperMaxFreq(newIndicesUpper);

lowerIndexCut=[1:7 110:120];
% lowerIndexCut=[];
newIndicesLower=setdiff(1:steps,lowerIndexCut);
lowerFluxVecCrop=fluxVec(newIndicesLower);
lowerMaxFreqCrop=lowerMaxFreq(newIndicesLower);

figure(78);
subplot(2,1,1);
plot(1:length(lowerMaxFreqCrop),lowerMaxFreqCrop,'b.',...
    1:length(upperMaxFreqCrop),upperMaxFreqCrop,'r.');
subplot(2,1,2);
plot(lowerFluxVecCrop,lowerMaxFreqCrop,'b.')
hold on;
plot(upperFluxVecCrop,upperMaxFreqCrop,'r.')
hold off;



%% Combo fit

%% Fit the data for the following parameters, wA,wB,beta,gI and g0 
% also ignore the factor of 2pi with w's and g's
tic
betaVec=linspace(0.80,0.9999,100);
fluxOffset=0.1;
fluxScaleFactor=1;
phiExtPlusVec=(upperFluxVecCrop-fluxOffset)./fluxScaleFactor;
extractedDataPlus=upperMaxFreqCrop*1e9;
phiExtMinusVec=(lowerFluxVecCrop-fluxOffset)./fluxScaleFactor;
extractedDataMinus=lowerMaxFreqCrop*1e9;
w0A=5.812e9; % for initial guess
w0B=5.865e9; % for initial guess
g0 = 20.7e6; % for initial guess
gI = 20e6;   % for initial guess
    
for i=1:length(betaVec)
    beta=betaVec(i);
    phiPlusVec=zeros(length(phiExtPlusVec),1);
    
    for j=1: length(phiExtPlusVec)
        %phiPlusVec(j)=vpasolve(2*pi*phiExtPlusVec(j)==x+beta*sin(x)); %
        %turns out vpasolve is 50 times slower than fzero. Maybe it is due
        %to the accuracy involved
        fun = @(x) 2*pi*phiExtPlusVec(j)-2*pi*x-beta*sin(2*pi*x);
        phiPlusVec(j) = fzero(fun,0.0);
    end    
    tau= @(phi)beta*cos(2*pi*phi)./(1+beta*cos(2*pi*phi));
    omegaPlus=@(p,phi)(p(1)+p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))...
        +sqrt((p(4)+p(3)*tau(phi)).^2+((p(1)-p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))).^2);
    
    phiMinusVec=zeros(length(phiExtMinusVec),1);
    
    for j=1: length(phiExtMinusVec)
        %phiMinusVec(j)=vpasolve(2*pi*phiExtMinusVec(j)==x+beta*sin(x)); %
        %turns out vpasolve is 50 times slower than fzero. Maybe it is due
        %to the accuracy involved
        fun = @(x) 2*pi*phiExtMinusVec(j)-2*pi*x-beta*sin(2*pi*x);
        phiMinusVec(j) = fzero(fun,0.0);
    end    
    tau= @(phi)beta*cos(2*pi*phi)./(1+beta*cos(2*pi*phi));
    omegaMinus=@(p,phi)(p(1)+p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))...
        -sqrt((p(4)+p(3)*tau(phi)).^2+((p(1)-p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))).^2);
    pguess=[w0A w0B g0 gI];
    lb=[4.5e9 4.5e9 0e6 0e6];
    ub=[7.5e9 7.5e9 1000e6 1000e6];
    options=optimset('MaxFunEvals',2000,'TolFun',1e-10,'TolX',1e-8,'MaxIter',1000);
    
    F=@(p)[omegaPlus(p,phiPlusVec)-extractedDataPlus';omegaMinus(p,phiMinusVec)-extractedDataMinus'];
    [pCombo(i,:),fCombo(i)]=lsqnonlin(F,pguess,lb,ub,options);
    
    
end
[~, bCombo]=min(fCombo);
pOptimal=pCombo(bCombo,:);
beta=betaVec(bCombo);
figure
plot(betaVec,fCombo);
xlabel('Beta')
ylabel('lsqError')
%% Test the fit for OmegaPlus
for j=1: length(phiExtPlusVec)
        %phiPlusVec(j)=vpasolve(2*pi*phiExtPlusVec(j)==x+beta*sin(x)); %
        %turns out vpasolve is 50 times slower than fzero. Maybe it is due
        %to the accuracy involved
        fun = @(x) 2*pi*phiExtPlusVec(j)-2*pi*x-beta*sin(2*pi*x);
        phiPlusVec(j) = fzero(fun,0.0);
end    
figure
plot(phiExtPlusVec,omegaPlus(pOptimal,phiPlusVec),'-',phiExtPlusVec,extractedDataPlus,'*')
xlabel('Ext Flux')
ylabel('Omega_{Plus}')

%% Test the fit for OmegaMinus
for j=1: length(phiExtMinusVec)
        %phiMinusVec(j)=vpasolve(2*pi*phiExtMinusVec(j)==x+beta*sin(x)); %
        %turns out vpasolve is 50 times slower than fzero. Maybe it is due
        %to the accuracy involved
        fun = @(x) 2*pi*phiExtMinusVec(j)-2*pi*x-beta*sin(2*pi*x);
        phiMinusVec(j) = fzero(fun,0.0);
end    
figure
plot(phiExtMinusVec,omegaMinus(pOptimal,phiMinusVec),'-',phiExtMinusVec,extractedDataMinus,'*')
xlabel('Ext Flux')
ylabel('Omega_{Minus}')
J=(pOptimal(4)+pOptimal(3)*tau(phiMinusVec)); % here it is g(phi) but in our exp it is J
phiExtVec=linspace(0,0.45,10001);
phiVec=zeros(length(phiExtVec),1);
splitting=omegaPlus(pOptimal,phiMinusVec)-omegaMinus(pOptimal,phiMinusVec);
for i=1:length(phiExtVec)
    fun = @(x) 2*pi*phiExtVec(j)-2*pi*x-beta*sin(2*pi*x);
    phiVec(j) = fzero(fun,0.0);
end
save('optimalFit_allFreeParams_112816_with_J','phiExtMinusVec','phiExtPlusVec','tau','omegaMinus',...
    'omegaPlus','pOptimal','phiMinusVec','pOptimal','phiPlusVec','extractedDataMinus',...
    'extractedDataPlus','beta','phiVec','phiExtVec','J','splitting');
toc
