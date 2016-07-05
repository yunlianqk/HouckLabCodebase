


N = 25;
X90p = 0.28;
%X90p = 0.26:0.002:0.3;
Y90p = 0.294;
%Y90p = 0.28:0.002:0.33;
X180p = 0.568;
%X180p = 0.55:0.002:0.59;
%Y180p = 0.58:0.002:0.63;
Y180p = 0.606;
%Y180m = -0.62:0.001:-0.56;
Y180m = -0.606;
X90m = -0.294;
%X90m = -0.33:0.002:-0.28;
Y90m = -0.292;
%Y90m = -0.33:0.002:-0.27;
X180m = -0.588;
%X180m = -0.61:0.002:-0.56;
dragamp = -0.4:0.01:0;
dragampy = 0.13;
dragampx = -0.13;
%specfreq = 5.734e9:0.1e6:5.738e9;
for counter1 = 1:length(X180m)
    %fprintf(instr.funcgen2,['freq ' num2str(specfreq(counter1))]);
    for counter2 = 1:N
        %Tune pi/2 rotations
        %AWG_PulseTuningPulseGenerator1(AWGHandle, X90m(counter1), 1, dragampx, counter2-1);
        %Tune drag and phase errors
      % AWG_PulseTuningPulseGenerator2(AWGHandle, [X90p,X90m], 1, dragamp(counter1), counter2-1);
        %Tune pi pulse
        AWG_PulseTuningPulseGenerator3(AWGHandle, [X90m X180m(counter1)], 1, dragampx, counter2-1);
 %      AWG_PulseTuningPulseGenerator4(AWGHandle, [Y90p Y180m Y180p], 0, dragamp(counter1), counter2-1);
        [rawi(counter2,:),rawq(counter2,:)] = readIandQ(CardParameters);
    end
    filti(counter1,:) = mean(rawi(:,1300:3200),2)-mean(rawi(:,200:800),2);
    filtq(counter1,:) = mean(rawq(:,1300:3200),2)-mean(rawq(:,200:800),2);
    clear rawi rawq;
end

% figure;
% subplot(2,1,1);plot(mean(rawi(:,1200:3200),2));
% subplot(2,1,2);plot(mean(rawq(:,1200:3200),2),'r');