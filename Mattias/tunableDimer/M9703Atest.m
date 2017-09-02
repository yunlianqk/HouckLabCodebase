% address='PXI0::CHASSIS1::SLOT2::FUNC0::INSTR'; % PXI address
% address='PXI0::11-0.0::INSTR'; % PXI address
% 
% addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\drivers')
% address = 'PXI0::CHASSIS1::SLOT2:FUNC0::INSTR'
% address='PXI0::11-0.0::INSTR'; % PXI address
address='PXI11::0::0::INSTR'; % PXI address

card=M9703ADigitizer64(address);  % create object
%% Set card parameters
cardparams=paramlib.m9703a();   %default parameters

%% Set the reference clock source and parameters for the card
set(card.instrID.Referenceoscillator,'Reference_Oscillator_Source',0)  %internal
% set(card.instrID.Referenceoscillator,'Reference_Oscillator_Source',1) %external 100 MHz on ref port
% set(card.instrID.Referenceoscillator,'Reference_Oscillator_Source',4) %Chassis 100 MHz system clock
disp(['clock source  = ' num2str(card.instrID.Referenceoscillator.Reference_Oscillator_Source)])

% %%
cardparams.samplerate=1.6e9/32;   % Hz units
cardparams.samples=100e-6*1.6e9/32;    % samples for a single trace
cardparams.averages=1;  % software averages PER SEGMENT; total avg=self.averages*self.segments
cardparams.segments=2; % segments>1 => sequence mode in readIandQ
cardparams.fullscale=1; % in units of V, IT CAN ONLY TAKE VALUE:1,2, other values will give an error
cardparams.offset=0;    % in units of volts
cardparams.couplemode='DC'; % 'DC'/'AC'
cardparams.delaytime=0.5e-6; % Delay time from trigger to start of acquistion, units second
% cardparams.trigSource='Channel1'; % Trigger source
cardparams.trigSource='External1'; % Trigger source
cardparams.trigLevel=0.5; % Trigger level in volts

triggen.period = 145e-6;

card.SetParams(cardparams);
%% Get parameters from digitizer hardware
card.GetParams()

%% read a channels, single segment
card.SetParams(cardparams); 

card.WaitTrigger(); %horrible name. This function clears any stale aquisition and gets ready for a new one. 
%May or may not be strictly necessary, but it does some housekeeping.
clear data
data = card.ReadChannels64([2,3]); %works
data1 = data(1,:);
data2 = data(2,:);

figure(1);
clf()
hold on
plot(data1)
plot(data2)
hold off
title('single segment from two channels')

disp(size(data))

%% read a channel multisegment
card.SetParams(cardparams); 

card.WaitTrigger(); %horrible name. This function clears any stale aquisition and gets ready for a new one. 
%May or may not be strictly necessary, but it does some housekeeping.
clear data
data = card.Read64_multiSeg('Channel2'); %works
% data = card.Read64_multiSeg(cardparams.ChI); %works


figure(2);
clf()
plot(data(1,:))
title('first segment of data')
% drawnow()

disp(size(data))


%% read a channels multisegment
card.SetParams(cardparams); 

card.WaitTrigger(); %horrible name. This function clears any stale aquisition and gets ready for a new one. 
%May or may not be strictly necessary, but it does some housekeeping.
clear data
data = card.ReadChannels64_multiSegment([3,4]);

data1 = squeeze(data(1,:,:)); %seperate first channel, and remove extra dimension
data2 = squeeze(data(2,:,:));

figure(3);
clf()
hold on
plot(data1(1,:))
plot(data2(1,:))
hold off
title('first segment of data from two channels')
disp(size(data))



%% junk
% %% Read multiple channels
% % Specifiy the channels
% chList = [1, 4, 5];
% cardparams.segments=10;
% card.SetParams(cardparams);
% % datArray is a M*N*L array, where
% % First index is channel number
% % Second index is segment number
% % Third index is sample number
% % The index is squeezed if it equals 1
% dataArray = card.ReadChannels(chList);
% figure();
% for index = 1:length(chList)
%     subplot(1, length(chList), index);
%     imagesc(taxis, (1:cardparams.segments), squeeze(dataArray(index, :, :)));
%     xlabel('Time (\mus)');
%     if index == 1
%         ylabel('Segment');
%     end
%     title(sprintf('Channel %d', chList(index)));
% end