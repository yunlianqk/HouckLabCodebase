
%%%%%%%%%%%%%%% INTIALIZATIONS
% CHECKLIST
% m8195a SFP open, with the following setting adjustments
%   - Clock tab: routing to Ref clock in(connected to the Rb clk)
%   - Output tab: chan 1V amp, Ch2(LO) 200mV amp (don't forget warm amp!)
%                 ch3(marker) 1V amp +0.5V offset
%   - Trigger tab: Trigger/Gate, Advance Event -> Trigger Inaddpath('C:\Users\newforce\Documents\GitHub\HouckLabMeasurementCode');

% Initialize awg object
cd 'C:\Users\newforce\Documents\GitHub\HouckLabMeasurementCode'
addpath('C:\Users\newforce\Documents\GitHub\HouckLabMeasurementCode');
% Choose settings in IQ config window -> press Ok
% Import FIR filter -> press Ok
awg = M8195AWG();
%% Generate vector for typical Rabi experiment
waveLength=20e-6;
tAxis=(1/awg.samplerate:1/awg.samplerate:waveLength);

% Readout pulse parameters
read.Amp=1;
read.Freq=4.772869998748302e9;
read.start=10e-6;
read.length=5e-6;
read.buffer=500e-9;
% Qubit gaussian pulse parameters
% varying amplitudes
qubit.Amp=[0 1];
qubit.Freq=4.772869998748302e9;
qubit.sigma=50e-9;
qubit.cutoff=4*qubit.sigma;
qubit.center=read.start-read.buffer-qubit.cutoff/2;
for i=1:length(qubit.Amp)
    % Base Gaussian waveform
    gauss=qubit.Amp(i).*exp(-(tAxis-qubit.center).^2/(2*qubit.sigma^2));
    % Apply cutoff
    offset=qubit.Amp(i)*exp(-qubit.cutoff^2/(8*qubit.sigma^2));
    gaussC(i,:)=(gauss-offset).*(tAxis>(qubit.center-qubit.cutoff/2)) ...
                         .*(tAxis<(qubit.center+qubit.cutoff/2));
    % Normalize
    if max(abs(gaussC(i,:))) ~=abs(qubit.Amp(i))
        gaussC(i,:)=gaussC(i,:)/max(abs(gaussC(i,:)))*abs(qubit.Amp(i));
    end

end

% Channel 1 waveform = Qubit pulse + Readout
for i=1:length(qubit.Amp)
    waveform1(i,:) = read.Amp*(tAxis>read.start & tAxis<read.start+read.length).*cos(2*pi*read.Freq*tAxis)+...
                gaussC(i,:).*cos(2*pi*qubit.Freq*tAxis);
end

% Channel 2 waveform = LO
lo.start=1e-6;
lo.Freq=read.Freq;
lo.end=read.start+read.length+2e-6;
waveform2 = cos(2*pi*lo.Freq*tAxis);

% Marker used as a trigger for digitizer
mark.start=0.01e-6;
mark.stop=0.5e-6;
marker=(tAxis>mark.start & tAxis<mark.stop);

figure();
subplot(1,2,1); hold on;
for i=1:length(qubit.Amp)
    plot(tAxis,waveform1(i,:)+2*i,'b')
    plot(tAxis,marker+2*i,'r')
end
hold off;
subplot(1,2,2)
plot(tAxis,waveform2,'r')
%% Create waveform library

for i=1:length(qubit.Amp)
    % Waveforms for Ch1
    WaveLib(2*i-1).waveform = waveform1(i,:);
    WaveLib(2*i-1).channelMap = [1 0;0 0;0 0;0 0];
    WaveLib(2*i-1).segNumber = i;
    WaveLib(2*i-1).keepOpen = 1;
    WaveLib(2*i-1).run = 0;
%     WaveLib(2*i-1).marker = marker;
    WaveLib(2*i-1).correction = 1;
    
    % Waveforms for Ch4
    WaveLib(2*i).waveform = waveform2;
    WaveLib(2*i).channelMap = [0 0;1 0;0 0;0 0];
    WaveLib(2*i).segNumber = i;
    WaveLib(2*i).keepOpen = 1;
    WaveLib(2*i).run = 0;
    WaveLib(2*i).correction = 1;
end
%% Send library to the awg
% awg.ApplyCorrection(WaveLib);
awg.Wavedownload(WaveLib);
%% Setup sequence playlist
clear PlayList
for i=1:(length(qubit.Amp)-1)
    %Channel 1+4 playlist
    PlayList(i).segmentNumber=i;
    PlayList(i).segmentLoops=1;
%     PlayList(i).markerEnable=true;
    PlayList(i).segmentAdvance='Stepped';
end

% last element of playlist needs to have 'auto' segment advance mode
last=length(qubit.Amp);
PlayList(last).segmentNumber=last;
PlayList(last).segmentLoops=1;
% PlayList(last).markerEnable=true;
PlayList(last).segmentAdvance='Auto';

%% Run sequence
awg.SeqRun(PlayList);
%% Use the digitizer to read the IQ mixed signal from the awg
% initialize digitizer
address='PXI0::CHASSIS1::SLOT2::FUNC0::INSTR'; % PXI address
card=M9703ADigitizer(address);  % create object
%% Set card parameters
cardparams=paramlib.m9703a();   %default parameters

cardparams.samplerate=1.6e9;   % Hz units
cardparams.samples=1.6e9*6.5e-6;    % samples for a single trace
cardparams.averages=1;  % software averages PER SEGMENT
cardparams.segments=1; % segments>1 => sequence mode in readIandQ
cardparams.fullscale=1; % in units of V, IT CAN ONLY TAKE VALUE:1,2, other values will give an error
cardparams.offset=0;    % in units of volts
cardparams.couplemode='DC'; % 'DC'/'AC'
cardparams.delaytime=10e-6; % Delay time from trigger to start of acquistion, units second
cardparams.ChI='Channel1';
cardparams.ChQ='Channel2';
cardparams.trigSource='External4'; % Trigger source
cardparams.trigLevel=0.5; % Trigger level in volts
cardparams.trigPeriod=50e-6; % Trigger period in seconds

% Update parameters and setup acquisition and trigerring 
card.SetParams(cardparams);
%%
awg.SeqStop(PlayList);
%% Read I and Q - averaged sequence mode
% Sequence of 10 segments
cardparams.segments=length(qubit.Amp);
card.SetParams(cardparams);
tstep=1/card.params.samplerate;
taxis=(tstep:tstep:card.params.samples/card.params.samplerate)'./1e-6;%mus units

% [Idata,I2data,Qdata,Q2data]=card.ReadIandQcomplicated(awg,PlayList);
[Idata, Qdata]=card.ReadIandQ(awg,PlayList);
%%
figure();
subplot(2,2,1);plot(taxis,Idata);
subplot(2,2,2);plot(taxis,Qdata);
subplot(2,2,3);plot(taxis,Idata.^2+Qdata.^2);
%%
% figure()
% subplot(1,2,1);
% for i=1:cardparams.segments/2
%     plot(taxis,Idata(i,:)+i*0.1);hold on;
% end
% xlabel('Time (\mus)');
% title('Inphase');
% subplot(1,2,2);
% for i=1:cardparams.segments/2
%     plot(taxis,Qdata(i,:)+i*0.1);hold on;
% end
% xlabel('Time (\mus)');
% title('Quadrature');
