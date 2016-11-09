% address='PXI0::CHASSIS1::SLOT2::FUNC0::INSTR'; % PXI address
address='PXI0::12-0.0::INSTR'; % PXI address
card=M9703ADigitizer(address);  % create object
%% Set card parameters
cardparams=paramlib.m9703a();   %default parameters

cardparams.samplerate=1.6e9;   % Hz units
cardparams.samples=1.6e9*1e-6;    % samples for a single trace
cardparams.averages=2000;  % software averages PER SEGMENT
cardparams.segments=1; % segments>1 => sequence mode in readIandQ
cardparams.fullscale=1; % in units of V, IT CAN ONLY TAKE VALUE:1,2, other values will give an error
cardparams.offset=0;    % in units of volts
cardparams.couplemode='DC'; % 'DC'/'AC'
cardparams.delaytime=5e-6; % Delay time from trigger to start of acquistion, units second
cardparams.ChI='Channel1';
cardparams.ChQ='Channel2';
cardparams.trigSource='External1'; % Trigger source
cardparams.trigLevel=0.5; % Trigger level in volts
cardparams.trigPeriod=10e-6; % Trigger period in seconds

% Update parameters and setup acquisition and trigerring 
card.SetParams(cardparams);
%% Get parameters from digitizer hardware
card.GetParams()
%% Read I and Q for - single averaged segment 
tstep=1/card.params.samplerate;
taxis=(tstep:tstep:card.params.samples/card.params.samplerate)'./1e-6;%mus units

[Idata, Qdata]=card.ReadIandQ();
% 
figure()
subplot(1,2,1);
plot(taxis, Idata);
xlabel('Time (\mus)');
ylabel('homod voltage (V)');
title('Inphase');
subplot(1,2,2);
plot(taxis, Qdata);
xlabel('Time (\mus)');
title('Quadrature');
%% Read I and Q - averaged sequence mode
% Sequence of 10 segments
cardparams.segments=10;
card.SetParams(cardparams);

[Idata, Qdata]=card.ReadIandQ();

figure()
subplot(1,2,1);
imagesc(taxis,(1:cardparams.segments),Idata);
xlabel('Time (\mus)');
ylabel('Segment number');
title('Inphase');
subplot(1,2,2);imagesc(taxis,(1:cardparams.segments),Qdata);
xlabel('Time (\mus)');
title('Quadrature');

%% Read multiple channels
% Specifiy the channels
chList = [1, 4, 5];
cardparams.segments=10;
card.SetParams(cardparams);
% datArray is a M*N*L array, where
% First index is channel number
% Second index is segment number
% Third index is sample number
% The index is squeezed if it equals 1
dataArray = card.ReadChannels(chList);
figure();
for index = 1:length(chList)
    subplot(1, length(chList), index);
    imagesc(taxis, (1:cardparams.segments), squeeze(dataArray(index, :, :)));
    xlabel('Time (\mus)');
    if index == 1
        ylabel('Segment');
    end
    title(sprintf('Channel %d', chList(index)));
end