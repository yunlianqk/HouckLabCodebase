function [moments] = photonCurrent_4chanHomodyne_v5(card,corrparams,dataMatrix_off)




pause(.5);


% Time Domain
% Single Mode
moments.a1= 0;
moments.a1daga1= 0;

moments.a2= 0;
moments.a2daga2= 0;

% Two Mode
moments.a1a2= 0;
moments.a1daga2= 0;
moments.a2daga1= 0;

moments.expO=0;
moments.expOSquared=0;

pause(0.1);
tic;

% Time Domain
a1_Tot  = 0;
a1daga1_Tot  = 0;

a2_Tot  = 0;
a2daga2_Tot  = 0;

a1a2_Tot  = 0;
a1daga2_Tot  = 0;
a2daga1_Tot  = 0;

expO_Tot = 0;
expOSquared_Tot = 0;

for limCounter = 1:corrparams.limCount % Number of soft averages.
    
    dataMatrix=card.ReadChannels64([2 3 4 5]);
    dataMatrix=dataMatrix-dataMatrix_off;
    
    S1_data = dataMatrix(1,:) + 1i.*dataMatrix(2,:);
    
%     S1dag_data = conj(S1_data);
    
%     S1dagS1_data = S1dag_data.*S1_data;
    
    a1 = mean(mean(S1_data,1),2);
    
    a1daga1 = mean(mean(conj(S1_data).*S1_data,1),2);
    
    a1_Tot = a1_Tot + a1;
    
    a1daga1_Tot = a1daga1_Tot + a1daga1;
    
    S2_data = dataMatrix(3,:) + 1i.*dataMatrix(4,:);
    
%     S2dag_data = conj(S2_data);
    
%     S2dagS2_data = conj(S2_data).*S2_data;
    
    a2 = mean(mean(S2_data,1),2);
    
    a2daga2 = mean(mean(conj(S2_data).*S2_data,1),2);
    
    expO=mean(mean(S1_data+S2_data,1),2);
    
    expO_Tot=expO_Tot+expO;
    
    expOSquared=mean(mean(abs(S1_data+S2_data).^2,1),2);
    
    expOSquared_Tot=expOSquared_Tot+expOSquared;
    
    a2_Tot = a2_Tot + a2;
    
    a2daga2_Tot = a2daga2_Tot + a2daga2;
    
    % Two Mode terms
    % a1a2
    S1S2_data = S1_data.*S2_data;
    S1S2 = mean((mean(S1S2_data,1)),2);
    
    a1a2 = S1S2;
    
    a1a2_Tot = a1a2_Tot + a1a2;
    
    % a1daga2
%     S1dagS2_data = conj(S1_data).*S2_data;
%     S1dagS2_Tot_data = S1dagS2_Tot_data + mean(S1dagS2_data,2);
    S1dagS2 = mean(mean(conj(S1_data).*S2_data,1),2);
    
    a1daga2 = S1dagS2;
    
    a1daga2_Tot = a1daga2_Tot + a1daga2;
    
    % a2daga1
%     S2dagS1_data = conj(S2_data).*S1_data;
%     S2dagS1_Tot_data = S2dagS1_Tot_data + mean(S2dagS1_data,2);
    S2dagS1 = mean(mean(conj(S2_data).*S1_data,1),2);
    
    a2daga1 = S2dagS1;
    
    a2daga1_Tot = a2daga1_Tot + a2daga1;
    
end

% memory

toc;
% Time Domain
% Single Mode
moments.a1= a1_Tot./limCounter;
moments.a1daga1= a1daga1_Tot./limCounter;

moments.a2= a2_Tot./limCounter;
moments.a2daga2= a2daga2_Tot./limCounter;

% Two Mode
moments.a1a2= a1a2_Tot./limCounter;
moments.a1daga2= a1daga2_Tot./limCounter;
moments.a2daga1= a2daga1_Tot./limCounter;

moments.expO = expO_Tot./limCounter;
moments.expOSquared = expOSquared_Tot./limCounter;

end

