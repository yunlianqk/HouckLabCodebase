function [moments] = photonCurrent_2ChanDigitalHomodyne(card,corrparams)

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

CH_params = SetupCH_Params_Blockade_Truncate(card.params.sampleinterval, corrparams.Int_Freq, card.params.samples, card.params.segments, 0);

for limCounter = 1:corrparams.limCount % Number of soft averages.
    
%     dataMatrix=card.ReadChannels64([2 3]);
%     dataMatrix=dataMatrix-dataMatrix_off;
    
    [I1data, I2data] = card.ReadIandQ();
    
    %ACcoupling
    I1data = I1data-mean(I1data);
    I2data = I2data-mean(I2data);
    
%     %fake data
%     I1data = CH_params.CosineVector + rand(1,CH_params.truncPoints)*0.1;
%     I2data = CH_params.SineVector + rand(1,CH_params.truncPoints)*0.1;
    
    % Signal for Output 1
    I1_Sig = I1data(1:CH_params.truncPoints)'.*CH_params.CosineVector';
    Q1_Sig = I1data(1:CH_params.truncPoints)'.*CH_params.SineVector';

%     figure(9);
%     plot(I1_Sig.^2+Q1_Sig.^2)
%     hold on;

%     %cheating filter
%     xs = linspace(-1,1,length(I1data));
%     sigma = 0.15;
%     gau = 1/(sigma * sqrt(2*pi))*exp(-xs.^2/(2*sigma^2));
    
    S1_data = I1_Sig + 1i.*Q1_Sig;

%     [S1_data, s1_f] = ghetto_filter_2_Truncate(S1_data,corrparams.LPF,card.params.sampleinterval);
    filter_sigma = 0.25/corrparams.LPF/card.params.sampleinterval;
    [S1_data, s1_f] = lessghetto_filter(S1_data,filter_sigma,card.params.sampleinterval);
    
    a1 = mean(mean(S1_data,1),2);
    
    a1daga1 = mean(mean(conj(S1_data).*S1_data,1),2);
    
    a1_Tot = a1_Tot + a1;
    
    a1daga1_Tot = a1daga1_Tot + a1daga1;
    
    % Signal for Output 2
    I2_Sig = I2data(1:CH_params.truncPoints)'.*CH_params.CosineVector';
    Q2_Sig = I2data(1:CH_params.truncPoints)'.*CH_params.SineVector';

%     plot(I2_Sig.^2+Q2_Sig.^2)
%     hold off;
    
    S2_data = I2_Sig + 1i.*Q2_Sig;

%     [S2_data, s2_f] = ghetto_filter_2_Truncate(S2_data,corrparams.LPF,card.params.sampleinterval);
    [S2_data, s2_f] = lessghetto_filter(S2_data,filter_sigma,card.params.sampleinterval);
    
    if limCounter ==1
       disp('I1 and S1')
       I1data_AC = I1data - mean(I1data);
%        rms(I1data)
       RMS1 = rms(I1data_AC);
%        mean(I1data.*conj(I1data))
       Av1 = mean(S1_data.*conj(S1_data));
        
       disp('I2 and S2')
       I2data_AC = I2data - mean(I2data);
%        rms(I2data)
       RMS2 = rms(I2data_AC);
%        mean(I2data.*conj(I2data))
       Av2 = mean(S2_data.*conj(S2_data));
%        disp([num2str(RMS1) '   ' num2str(RMS2)]);
       disp([num2str(Av1) '   ' num2str(Av2)]);
       
       
%        figure(23);
%        subplot(2,2,1);
%        plot(I1data)
%        title('I1data');
%        subplot(2,2,2);
%        plot(abs(S1_data))
%        title(['abs(S1_data)  rms = ' num2str(RMS1)]);
%        ylim([0 1.1*max(abs(S1_data))])
%     
%        subplot(2,2,3);
%        plot(I2data)
%        title('I2data');
%        subplot(2,2,4);
%        plot(abs(S2_data))
%        title(['abs(S2_data)  rms = ' num2str(RMS2)]);
%        ylim([0 1.1*max(abs(S2_data))])

    end
    
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

