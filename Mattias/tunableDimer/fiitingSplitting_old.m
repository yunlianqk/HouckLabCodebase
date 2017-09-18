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


% upperIndexCut=[1:4 106:115];
upperIndexCut=[];
newIndicesUpper=setdiff(1:steps,upperIndexCut);
upperFluxVecCrop=fluxVec(newIndicesUpper);
upperMaxFreqCrop=upperMaxFreq(newIndicesUpper);

lowerIndexCut=[1:7 100:120];
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
betaVec=linspace(0.90,0.9999,20);
fluxOffset=0.2;
fluxScaleFactor=1.1;
phiExtPlusVec=(upperFluxVecCrop-fluxOffset)./fluxScaleFactor;
extractedDataPlus=upperMaxFreqCrop*1e9;
phiExtMinusVec=(lowerFluxVecCrop-fluxOffset)./fluxScaleFactor;
extractedDataMinus=lowerMaxFreqCrop*1e9;
w0A=5.812e9; % for initial guess
w0B=5.865e9; % for initial guess
g0 = 20.7e6; % for initial guess
gI = 20e6;   % for initial guess
    
    %tau= beta*cos(2*pi*phi)/1+beta*cos(2*pi*phi);
    %Omega_plus=(wA+wB)/2*(1+g0/sqrt(wA*wB))+sqrt((gI+g0*tau)^2+((wA+wB)/2*(1+g0/sqrt(wA*wB)))^2);

%syms x% assume phi and phi_ext to be in terms of phi0


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
    ub=[7.5e9 7.5e9 500e6 500e6];
    options=optimset('MaxFunEvals',6000,'TolFun',1e-9,'TolX',1e-8,'MaxIter',800);
    
    F=@(p)[omegaPlus(p,phiPlusVec)-extractedDataPlus';omegaMinus(p,phiMinusVec)-extractedDataMinus'];
    [pCombo(i,:),fCombo(i)]=lsqnonlin(F,pguess,lb,ub,options);
    
    
end
[~, bCombo]=min(fCombo);
pOptimal=pCombo(bCombo,:);
beta=betaVec(bCombo);
figure(233);
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

phiExtVec=linspace(0,0.45,10001);

phiVec=zeros(length(phiExtVec),1);
for i=1:length(phiExtVec)
    fun = @(x) 2*pi*phiExtVec(i)-2*pi*x-beta*sin(2*pi*x);
    phiVec(i) = fzero(fun,0.0);
end

figure();
plot(phiExtVec,phiVec)


save('optimalFit_allFreeParams_112816','phiExtMinusVec','phiExtPlusVec','tau','omegaMinus',...
    'omegaPlus','pOptimal','phiMinusVec','pOptimal','phiPlusVec','extractedDataMinus',...
    'extractedDataPlus','beta','phiVec','phiExtVec');
toc
%% The commented part includes different ways to do the fitting
%%
% %% Fit the data for the following parameters, wA,wB,beta,gI and g0 
% % also ignore the factor of 2pi with w's and g's
% tic
% betaVec=linspace(0.65,0.999,100);
% fluxOffset=0.0;
% fluxScaleFactor=1;
% phiExtPlusVec=(upperFluxVecCrop-fluxOffset)./fluxScaleFactor;
% extractedDataPlus=upperMaxFreqCrop*1e9;
% phiExtMinusVec=(lowerFluxVecCrop-fluxOffset)./fluxScaleFactor;
% extractedDataMinus=lowerMaxFreqCrop*1e9;
% w0A=5.812e9; % for initial guess
% w0B=5.865e9; % for initial guess
% g0 = 20.7e6; % for initial guess
% gI = 20e6;   % for initial guess
%     
%     %tau= beta*cos(2*pi*phi)/(1+beta*cos(2*pi*phi));
%     %Omega_plus=(wA+wB)/2*(1+g0/sqrt(wA*wB))+sqrt((gI+g0*tau)^2+((wA+wB)/2*(1+g0/sqrt(wA*wB)))^2);
% 
% %syms x% assume phi and phi_ext to be in terms of phi0
% 
% % Plus
% for i=1:length(betaVec)
%     beta=betaVec(i);
%     phiPlusVec=zeros(length(phiExtPlusVec),1);
%     
%     for j=1: length(phiExtPlusVec)
%         %phiPlusVec(j)=vpasolve(2*pi*phiExtPlusVec(j)==x+beta*sin(x)); %
%         %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%         %to the accuracy involved
%         fun = @(x) 2*pi*phiExtPlusVec(j)-2*pi*x-beta*sin(2*pi*x);
%         phiPlusVec(j) = fzero(fun,0.0);
%     end    
%     tau= @(phi)beta*cos(2*pi*phi)./(1+beta*cos(2*pi*phi));
%     omegaPlus=@(p,phi)(p(1)+p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))...
%         +sqrt((p(4)+p(3)*tau(phi)).^2+((p(1)-p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))).^2);
%     pguess=[w0A w0B g0 gI];
%     lb=[4.5e9 4.5e9 0e6 0e6];
%     ub=[7.5e9 7.5e9 500e6 500e6];
%     options=optimset('MaxFunEvals',1000);
%     [pPlus(i,:),fPlus(i)]= lsqcurvefit(omegaPlus,pguess,phiPlusVec,extractedDataPlus',lb,ub,options);
%     
% end
% [~, bPlus]=min(fPlus);
% beta=betaVec(bPlus);
% figure
% plot(betaVec,fPlus);
% xlabel('Beta')
% ylabel('lsqError')
% %% Test the fit
% for j=1: length(phiExtPlusVec)
%         %phiPlusVec(j)=vpasolve(2*pi*phiExtPlusVec(j)==x+beta*sin(x)); %
%         %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%         %to the accuracy involved
%         fun = @(x) 2*pi*phiExtPlusVec(j)-2*pi*x-beta*sin(2*pi*x);
%         phiPlusVec(j) = fzero(fun,0.0);
% end    
% figure
% plot(phiExtPlusVec,omegaPlus(pPlus(bPlus,:),phiPlusVec),'-',phiExtPlusVec,extractedDataPlus,'*')
% xlabel('Ext Flux')
% ylabel('Omega_{Plus}')
% %% Repeat for Minus
% % Minus
% for i=1:length(betaVec)
%     beta=betaVec(i);
%     phiMinusVec=zeros(length(phiExtMinusVec),1);
%     
%     for j=1: length(phiExtMinusVec)
%         %phiMinusVec(j)=vpasolve(2*pi*phiExtMinusVec(j)==x+beta*sin(x)); %
%         %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%         %to the accuracy involved
%         fun = @(x) 2*pi*phiExtMinusVec(j)-2*pi*x-beta*sin(2*pi*x);
%         phiMinusVec(j) = fzero(fun,0.0);
%     end    
%     tau= @(phi)beta*cos(2*pi*phi)./1+beta*cos(2*pi*phi);
%     omegaMinus=@(p,phi)(p(1)+p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))...
%         -sqrt((p(4)+p(3)*tau(phi)).^2+((p(1)-p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))).^2);
%     pguess=[w0A w0B g0 gI];
%     lb=[4.5e9 4.5e9 0e6 0e6];
%     ub=[7.5e9 7.5e9 500e6 500e6];
%     options=optimset('MaxFunEvals',1000);
%     [pMinus(i,:),fMinus(i)]= lsqcurvefit(omegaMinus,pguess,phiMinusVec,extractedDataMinus',lb,ub,options);
%     
% end
% [~, bMinus]=min(fMinus);
% beta=betaVec(bMinus);
% figure
% plot(betaVec,fMinus);
% xlabel('Beta')
% ylabel('lsqError')
% %% Test the fit
% for j=1: length(phiExtMinusVec)
%         %phiMinusVec(j)=vpasolve(2*pi*phiExtMinusVec(j)==x+beta*sin(x)); %
%         %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%         %to the accuracy involved
%         fun = @(x) 2*pi*phiExtMinusVec(j)-2*pi*x-beta*sin(2*pi*x);
%         phiMinusVec(j) = fzero(fun,0.0);
% end    
% figure
% plot(phiExtMinusVec,omegaMinus(pMinus(bMinus,:),phiMinusVec),'-',phiExtMinusVec,extractedDataMinus,'*')
% xlabel('Ext Flux')
% ylabel('Omega_{Minus}')
%%
% %% Combo fit with freedom on offset and scaling of phi
% 
% %% Fit the data for the following parameters, wA,wB,beta,gI and g0 
% % also ignore the factor of 2pi with w's and g's
% tic
% betaVec=linspace(0.65,0.999,100);
% fluxOffset=0.0;
% fluxScaleFactor=1;
% phiExtPlusVec=(upperFluxVecCrop-fluxOffset)./fluxScaleFactor;
% extractedDataPlus=upperMaxFreqCrop*1e9;
% phiExtMinusVec=(lowerFluxVecCrop-fluxOffset)./fluxScaleFactor;
% extractedDataMinus=lowerMaxFreqCrop*1e9;
% w0A=5.812e9; % for initial guess
% w0B=5.865e9; % for initial guess
% g0 = 20.7e6; % for initial guess
% gI = 20e6;   % for initial guess
%     
%     %tau= beta*cos(2*pi*phi)/.(1+beta*cos(2*pi*phi));
%     %Omega_plus=(wA+wB)/2*(1+g0/sqrt(wA*wB))+sqrt((gI+g0*tau)^2+((wA+wB)/2*(1+g0/sqrt(wA*wB)))^2);
% 
% %syms x% assume phi and phi_ext to be in terms of phi0
% 
% % Plus
% for i=1:length(betaVec)
%     beta=betaVec(i);
%     phiPlusVec=zeros(length(phiExtPlusVec),1);
%     
%     for j=1: length(phiExtPlusVec)
%         %phiPlusVec(j)=vpasolve(2*pi*phiExtPlusVec(j)==x+beta*sin(x)); %
%         %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%         %to the accuracy involved
%         fun = @(x) 2*pi*phiExtPlusVec(j)-2*pi*x-beta*sin(2*pi*x);
%         phiPlusVec(j) = fzero(fun,0.0);
%     end    
%     tau= @(phi)beta*cos(2*pi*phi)./(1+beta*cos(2*pi*phi));
%     omegaPlus=@(p,phi)(p(1)+p(2))/2*(1+p(3)*tau(p(5)*phi+p(6))/sqrt(p(1)*p(2)))...
%         +sqrt((p(4)+p(3)*tau(p(5)*phi+p(6))).^2+((p(1)-p(2))/2*(1+p(3)*tau(p(5)*phi+p(6))/sqrt(p(1)*p(2)))).^2);
%     
%     phiMinusVec=zeros(length(phiExtMinusVec),1);
%     
%     for j=1: length(phiExtMinusVec)
%         %phiMinusVec(j)=vpasolve(2*pi*phiExtMinusVec(j)==x+beta*sin(x)); %
%         %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%         %to the accuracy involved
%         fun = @(x) 2*pi*phiExtMinusVec(j)-2*pi*x-beta*sin(2*pi*x);
%         phiMinusVec(j) = fzero(fun,0.0);
%     end    
%     tau= @(phi)beta*cos(2*pi*phi)./1+beta*cos(2*pi*phi);
%     omegaMinus=@(p,phi)(p(1)+p(2))/2*(1+p(3)*tau(p(5)*phi+p(6))/sqrt(p(1)*p(2)))...
%         -sqrt((p(4)+p(3)*tau(p(5)*phi+p(6))).^2+((p(1)-p(2))/2*(1+p(3)*tau(p(5)*phi+p(6))/sqrt(p(1)*p(2)))).^2);
%     pguess=[w0A w0B g0 gI 1 0];
%     lb=[4.5e9 4.5e9 0e6 0e6 -10 -10];
%     ub=[7.5e9 7.5e9 500e6 500e6 10 10];
%     options=optimset('MaxFunEvals',2000,'TolFun',1e-9,'TolX',1e-8,'MaxIter',600);
%     %[pMinus(i,:),fMinus(i)]= lsqcurvefit(omegaMinus,pguess,phiMinusVec,extractedDataMinus',lb,ub,options);
%     F=@(p)[omegaPlus(p,phiPlusVec)-extractedDataPlus';omegaMinus(p,phiMinusVec)-extractedDataMinus'];
%     [pCombo(i,:),fCombo(i)]=lsqnonlin(F,pguess,lb,ub,options);
%     %[pPlus(i,:),fPlus(i)]= lsqcurvefit(omegaPlus,pguess,phiPlusVec,extractedDataPlus',lb,ub,options);
%     
% end

%% Combo fit with freedom on x axis of external phi
%% Fit the data for the following parameters, wA,wB,beta,gI and g0 
% also ignore the factor of 2pi with w's and g's
% tic
% betaVec=linspace(0.82,0.999,30);
% fluxOffset=0.0;
% fluxScaleFactor=1;
% phiExtPlusVec=(upperFluxVecCrop-fluxOffset)./fluxScaleFactor;
% extractedDataPlus=upperMaxFreqCrop*1e9;
% phiExtMinusVec=(lowerFluxVecCrop-fluxOffset)./fluxScaleFactor;
% extractedDataMinus=lowerMaxFreqCrop*1e9;
% wA=p(1);%5.8161e9; % obtained from prev fitting
% wB=p(2);%5.8686e9; % obtained from prev fitting
% g0 = p(3);%9.27e6; % obtained from prev fitting
% gI = p(4);%8.26e6; % obtained from prev fitting
%     
%     %tau= beta*cos(2*pi*phi)/1+beta*cos(2*pi*phi);
%     %Omega_plus=(wA+wB)/2*(1+g0/sqrt(wA*wB))+sqrt((gI+g0*tau)^2+((wA+wB)/2*(1+g0/sqrt(wA*wB)))^2);
% 
% %syms x% assume phi and phi_ext to be in terms of phi0
% ScaleVec=linspace(0.6,1.8,9);
% OffsetVec=linspace(0,0.2,8);
% Error=zeros(length(ScaleVec),length(OffsetVec),length(betaVec));
% for k=1:length(ScaleVec)
%     for l=1:length(OffsetVec)
% 
%         for i=1:length(betaVec)
%             beta=betaVec(i);
%             phiPlusVec=zeros(length(phiExtPlusVec),1);
% 
%             for j=1: length(phiExtPlusVec)
%                 %phiPlusVec(j)=vpasolve(2*pi*phiExtPlusVec(j)==x+beta*sin(x)); %
%                 %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%                 %to the accuracy involved
%                 fun = @(x) 2*pi*(ScaleVec(k)*phiExtPlusVec(j)-OffsetVec(l))-2*pi*x-beta*sin(2*pi*x);
%                 phiPlusVec(j) = fzero(fun,0.0);
%             end    
%             tau= @(phi)beta*cos(2*pi*phi)./(1+beta*cos(2*pi*phi));
%             omegaPlus=@(p,phi)(p(1)+p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))...
%                 +sqrt((p(4)+p(3)*tau(phi)).^2+((p(1)-p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))).^2);
% 
%             phiMinusVec=zeros(length(phiExtMinusVec),1);
% 
%             for j=1: length(phiExtMinusVec)
%                 %phiMinusVec(j)=vpasolve(2*pi*phiExtMinusVec(j)==x+beta*sin(x)); %
%                 %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%                 %to the accuracy involved
%                 fun = @(x) 2*pi*(ScaleVec(k)*phiExtMinusVec(j)-OffsetVec(l))-2*pi*x-beta*sin(2*pi*x);
%                 phiMinusVec(j) = fzero(fun,0.0);
%             end    
%             tau= @(phi)beta*cos(2*pi*phi)./(1+beta*cos(2*pi*phi));
%             omegaMinus=@(p,phi)(p(1)+p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))...
%                 -sqrt((p(4)+p(3)*tau(phi)).^2+((p(1)-p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))).^2);
%            
%             F=@(p)[omegaPlus(p,phiPlusVec)-extractedDataPlus';omegaMinus(p,phiMinusVec)-extractedDataMinus'];
%             Error(k,l,i)=norm(F([wA wB g0 gI]));
%             display([k,l,i]);
%         end
%     end
% end
% minVal=min(min(min(Error)));
% linInd=find(Error==minVal);
% [scaleInd,offsetInd,betaInd]=ind2sub(size(Error),linInd);
% 
% beta=betaVec(betaInd);
% Scale=ScaleVec(scaleInd);
% offset=OffsetVec(offsetInd);
% 
% figure
% subplot(3,1,1);
% plot(betaVec,squeeze(Error(scaleInd,offsetInd,:)));
% ylabel('Error');
% xlabel('Beta');
% 
% subplot(3,1,2);
% plot(ScaleVec,squeeze(Error(:,offsetInd,betaInd)));
% ylabel('Error');
% xlabel('Scale factor for PhiExt');
% 
% subplot(3,1,3);
% plot(OffsetVec,squeeze(Error(scaleInd,:,betaInd)));
% ylabel('Error');
% xlabel('Offset for PhiExt');
% %% Now use the values of scale and offset obtained to again find values of parameters
% %% Combo fit
% 
% %% Fit the data for the following parameters, wA,wB,beta,gI and g0 
% % also ignore the factor of 2pi with w's and g's
% tic
% betaVec=linspace(0.85,0.9999,100);
% fluxOffset=0;%offset; % using values obtained in prev part
% fluxScaleFactor=1;%Scale; % using values obtained in prev part
% phiExtPlusVec=(fluxScaleFactor*upperFluxVecCrop-fluxOffset);
% extractedDataPlus=upperMaxFreqCrop*1e9;
% phiExtMinusVec=(fluxScaleFactor*lowerFluxVecCrop-fluxOffset);
% extractedDataMinus=lowerMaxFreqCrop*1e9;
% w0A=5.812e9; % for initial guess
% w0B=5.865e9; % for initial guess
% g0 = 20.7e6; % for initial guess
% gI = 20e6;   % for initial guess
%     
%     %tau= beta*cos(2*pi*phi)/1+beta*cos(2*pi*phi);
%     %Omega_plus=(wA+wB)/2*(1+g0/sqrt(wA*wB))+sqrt((gI+g0*tau)^2+((wA+wB)/2*(1+g0/sqrt(wA*wB)))^2);
% 
% %syms x% assume phi and phi_ext to be in terms of phi0
% 
% % Plus
% for i=1:length(betaVec)
%     beta=betaVec(i);
%     phiPlusVec=zeros(length(phiExtPlusVec),1);
%     
%     for j=1: length(phiExtPlusVec)
%         %phiPlusVec(j)=vpasolve(2*pi*phiExtPlusVec(j)==x+beta*sin(x)); %
%         %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%         %to the accuracy involved
%         fun = @(x) 2*pi*phiExtPlusVec(j)-2*pi*x-beta*sin(2*pi*x);
%         phiPlusVec(j) = fzero(fun,0.0);
%     end    
%     tau= @(phi)beta*cos(2*pi*phi)./(1+beta*cos(2*pi*phi));
%     omegaPlus=@(p,phi)(p(1)+p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))...
%         +sqrt((p(4)+p(3)*tau(phi)).^2+((p(1)-p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))).^2);
%     
%     phiMinusVec=zeros(length(phiExtMinusVec),1);
%     
%     for j=1: length(phiExtMinusVec)
%         %phiMinusVec(j)=vpasolve(2*pi*phiExtMinusVec(j)==x+beta*sin(x)); %
%         %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%         %to the accuracy involved
%         fun = @(x) 2*pi*phiExtMinusVec(j)-2*pi*x-beta*sin(2*pi*x);
%         phiMinusVec(j) = fzero(fun,0.0);
%     end    
%     tau= @(phi)beta*cos(2*pi*phi)./(1+beta*cos(2*pi*phi));
%     omegaMinus=@(p,phi)(p(1)+p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))...
%         -sqrt((p(4)+p(3)*tau(phi)).^2+((p(1)-p(2))/2*(1+p(3)*tau(phi)/sqrt(p(1)*p(2)))).^2);
%     pguess=[w0A w0B g0 gI];
%     lb=[4.5e9 4.5e9 0e6 0e6];
%     ub=[7.5e9 7.5e9 500e6 500e6];
%     options=optimset('MaxFunEvals',1000);%'TolFun',1e-9,'TolX',1e-8,'MaxIter',600);
%     %[pMinus(i,:),fMinus(i)]= lsqcurvefit(omegaMinus,pguess,phiMinusVec,extractedDataMinus',lb,ub,options);
%     F=@(p)[omegaPlus(p,phiPlusVec)-extractedDataPlus';omegaMinus(p,phiMinusVec)-extractedDataMinus'];
%     [pCombo(i,:),fCombo(i)]=lsqnonlin(F,pguess,lb,ub,options);
%     %[pPlus(i,:),fPlus(i)]= lsqcurvefit(omegaPlus,pguess,phiPlusVec,extractedDataPlus',lb,ub,options);
%     
% end
% 
% %% Find optimal beta
% [~, bCombo]=min(fCombo);
% beta=betaVec(bCombo);
% figure
% plot(betaVec,fCombo);
% xlabel('Beta')
% ylabel('lsqError')
% %% Test the fit for OmegaPlus
% for j=1: length(phiExtPlusVec)
%         %phiPlusVec(j)=vpasolve(2*pi*phiExtPlusVec(j)==x+beta*sin(x)); %
%         %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%         %to the accuracy involved
%         fun = @(x) 2*pi*phiExtPlusVec(j)-2*pi*x-beta*sin(2*pi*x);
%         phiPlusVec(j) = fzero(fun,0.0);
% end    
% figure
% plot(phiExtPlusVec,omegaPlus(pCombo(bCombo,:),phiPlusVec),'-',phiExtPlusVec,extractedDataPlus,'*')
% xlabel('Ext Flux')
% ylabel('Omega_{Plus}')
% 
% %% Test the fit for OmegaMinus
% for j=1: length(phiExtMinusVec)
%         %phiMinusVec(j)=vpasolve(2*pi*phiExtMinusVec(j)==x+beta*sin(x)); %
%         %turns out vpasolve is 50 times slower than fzero. Maybe it is due
%         %to the accuracy involved
%         fun = @(x) 2*pi*phiExtMinusVec(j)-2*pi*x-beta*sin(2*pi*x);
%         phiMinusVec(j) = fzero(fun,0.0);
% end    
% figure
% plot(phiExtMinusVec,omegaMinus(pCombo(bCombo,:),phiMinusVec),'-',phiExtMinusVec,extractedDataMinus,'*')
% xlabel('Ext Flux')
% ylabel('Omega_{Minus}')
% toc    