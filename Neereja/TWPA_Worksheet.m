%TWPA Worksheet 9/12/16 '
global specgen;
specgen = E8267DGenerator(24);
global pnax
pnax = PNAXAnalyzer(16);
%%
gen.Power = 11:0.2:15;
gen.Freq = 8.25e9;

% gen.Power = 13.2;
% gen.Freq = 8.23e9:1e4:8.27e9;

pnax.SetActiveTrace(1);
transWaitTime=20;
pnax.params.start = 3e9;
pnax.params.stop = 9e9;
pnax.params.points = 5001;
pnax.params.power = -55;
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;

specgen.SetFreq(gen.Freq(1));
specgen.SetPower(gen.Power(1));

specgen.PowerOff();
pnax.ClearChannelAverages(1);
pause(120);
freq = pnax.ReadAxis();
S21_noPump = pnax.Read();
specgen.PowerOn();

S21 = zeros(length(gen.Freq), pnax.params.points);
Gain = S21;
for i = 1:length(gen.Freq)
    specgen.SetFreq(gen.Freq(i));
    S21 = zeros(length(gen.Power), pnax.params.points);
    Gain = S21;
    for i = 1:length(gen.Power)
        specgen.SetPower(gen.Power(i));
        pnax.ClearChannelAverages(1);
        pause(transWaitTime);
        S21(i,:) = pnax.Read();
        Gain(i,:) = S21(i,:) - S21_noPump;
        figure(17);
        imagesc(freq, gen.Power(1:i), S21(1:i,:),[-40 0]);
        colormap(jet(256));
        figure(19);
        
        imagesc(freq, gen.Power(1:i), Gain(1:i,:), [0 40]);
        colormap(jet(256));
    end
    % save('C:\Users\newforce\Documents\Data\160912_TWPA_ Testing\OptPumpFreq_13.2dBm_1.mat', 'gen', 'pnax','S21', 'freq', 'S21_noPump');
    save('C:\Users\newforce\Documents\Data\160912_TWPA_ Testing\OptPumpPower_8.25GHz_1.mat', 'gen', 'pnax','S21', 'freq', 'S21_noPump');
end
    %% Analysis:
    data = S21 - ones(length(gen.Freq), 1)*S21_noPump;
    figure(11); imagesc(freq, gen.Freq, data, [0 35]); colormap(hot(256)); set(gca, 'ydir', 'normal');
    %%
    data = S21 - ones(length(gen.Power), 1)*S21_noPump;
    figure(12); imagesc(freq, gen.Power, data, [0 30]); colormap(hot(256)); set(gca, 'ydir', 'normal');
    %%
    for i = 12
        figure(1); plot(freq, smooth(squeeze(S21(i,:) - S21_noPump),5));
        title(num2str(gen.Power(i)));
        % title(num2str(gen.Pow(i)./1e9));
        
        ylim([0 40]);
        xlim([2.5e9 9e9])
        waitforbuttonpress
    end
    %% Vary Both Freq and Power of Pump.
    clear S21 Gain
    gen.Power = 11:0.2:14.6;
    gen.Freq = 8.2e9:1e6:8.26e9;
    
    pnax.SetActiveTrace(1);
    transWaitTime=30;
    pnax.params.start = 3e9;
    pnax.params.stop = 10e9;
    pnax.params.points = 5001;
    pnax.params.power = -55;
    pnax.params.averages = 65536;
    pnax.params.ifbandwidth = 10e3;
    
    specgen.SetFreq(gen.Freq(1));
    specgen.SetPower(gen.Power(1));
    
    S21 = zeros(length(gen.Freq),length(gen.Power), pnax.params.points);
    S21_noPump = zeros(length(gen.Freq), pnax.params.points);
    Gain = S21;
    
    for k = 1:length(gen.Freq)
        specgen.SetFreq(gen.Freq(k));
        specgen.PowerOff();
        pnax.ClearChannelAverages(1);
        pause(120);
        freq = pnax.ReadAxis();
        S21_noPump(k,:) = pnax.Read();
        specgen.PowerOn();
        
        for j = 1:length(gen.Power)
            specgen.SetPower(gen.Power(j));
            pnax.ClearChannelAverages(1);
            pause(transWaitTime);
            
            S21(k,j,:) = pnax.Read();
            Gain(k,j,:) = squeeze(S21(k,j,:)) - squeeze(S21_noPump(k,:)');
            
            figure(17);
            imagesc(freq, gen.Power(1:j),squeeze(S21(k,1:j,:)),[-40 0]);
            colormap(jet(256));
            figure(19);
            imagesc(freq, gen.Power(1:j),squeeze(Gain(k,1:j,:)), [0 40]);
            colormap(jet(256));
        end
        save(['C:\Users\newforce\Documents\Data\160912_TWPA_ Testing\OptPumpFreqPower_SecondOvernight_' num2str(k) '.mat'], 'gen', 'pnax','S21', 'freq', 'S21_noPump');
    end
%%
for i = 1:1:30
figure(1);
imagesc(freq(1:4168), gen.Power(26:36),squeeze(Gain(i,26:36,1:4168)), [0 30]); colorbar; colormap(hot(256));
title(num2str(gen.Freq(i)./1e9));
pause(.51);
end
%%
figure(2);
hold off
pow = 32;
for i = 40%71:-5:1;
plot(freq(1:4168), smooth(squeeze(Gain(i, pow, 1:4168)),3));
hold on;
% pause(0.2);
waitforbuttonpress
end
%%
figure(2);
hold off
i = 25;
for pow = 40:5:60
plot(freq(1:4168), smooth(squeeze(Gain(i, pow, 1:4168)),4));
hold on;
pause(0.2);
end
%%
 %% Vary Both Freq and Power of Pump.
    clear S21 Gain
    gen.Power = 13.2;
    gen.Freq = 8.22e9:5e6:8.255e9;
    
    pnax.SetActiveTrace(1);
    transWaitTime=3;
    pnax.params.start = 3e9;
    pnax.params.stop = 8e9;
    pnax.params.points = 5001;
    pnax.params.averages = 65536;
    pnax.params.ifbandwidth = 10e3;
    pnaxPower = -55:1:-20;
    
    specgen.SetFreq(gen.Freq(1));
    specgen.SetPower(gen.Power(1));
    
    S21 = zeros(length(gen.Freq),length(pnaxPower), pnax.params.points);
    S21_noPump = zeros(length(gen.Freq), pnax.params.points);
    Gain = S21;
    
    for k = 1:length(gen.Freq)
        specgen.SetFreq(gen.Freq(k));
        specgen.PowerOff();
        pnax.ClearChannelAverages(1);
        pause(3);
        freq = pnax.ReadAxis();
        S21_noPump(k,:) = pnax.Read();
        specgen.PowerOn();
        
        for j = 1:length(pnaxPower)
            pnax.params.power = pnaxPower(j);
            pnax.ClearChannelAverages(1);
            pause(transWaitTime);
            
            S21(k,j,:) = pnax.Read();
%             Gain(k,j,:) = squeeze(S21(k,j,:)) - squeeze(S21_noPump(k,:)');
            
            figure(17);
            imagesc(freq, pnaxPower(1:j),squeeze(S21(k,1:j,:)),[-40 0]);
%             colormap(jet(256));
%             figure(19);
%             imagesc(freq, gen.Power(1:j),squeeze(Gain(k,1:j,:)), [0 40]);
%             colormap(jet(256));
        end
        save(['C:\Users\newforce\Documents\Data\160912_TWPA_ Testing\DynamicRange_VaryFreq.mat'], 'gen', 'pnax','S21', 'freq', 'S21_noPump', 'Gain', 'pnaxPower');
    end