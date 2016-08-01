% script for running transmission scan with M8195A
%% initialize awg 
% Choose settings in IQ config window -> press Ok
% Import FIR filter -> press Ok
awg = M8195AWG();
%% initialize digitizer
address='PXI0::CHASSIS1::SLOT2::FUNC0::INSTR'; % PXI address
card=M9703ADigitizer(address);  % create object

%% Set card parameters
cardparams=paramlib.m9703a();   %default parameters

cardparams.samplerate=1.6e9;   % Hz units
cardparams.samples=1.6e9*7e-6;    % samples for a single trace
cardparams.averages=1;  % software averages PER SEGMENT
cardparams.segments=5; % segments>1 => sequence mode in readIandQ
cardparams.fullscale=1; % in units of V, IT CAN ONLY TAKE VALUE:1,2, other values will give an error
cardparams.offset=0;    % in units of volts
cardparams.couplemode='DC'; % 'DC'/'AC'
cardparams.delaytime=9e-6; % Delay time from trigger to start of acquistion, units second
cardparams.ChI='Channel1';
cardparams.ChQ='Channel2';
cardparams.trigSource='External1'; % Trigger source
cardparams.trigLevel=0.2; % Trigger level in volts
cardparams.trigPeriod=100e-6; % Trigger period in seconds

% Update parameters and setup acquisition and trigerring 
card.SetParams(cardparams);

%% edit this code to change scan settings
open('explib.SweepTransmissionFrequency')

%% create experiment object
clear x w
x = explib.SweepTransmissionFrequency();
w = x.genWaveset_M8195A();

%% visualize
w.drawSegmentLibrary()
w.drawPlaylist()

%% Send library to the awg
% awg.ApplyCorrection(WaveLib);
% awg.Wavedownload(WaveLib);
awg.WavesetApplyCorrection(w);
awg.WavesetDownloadSegmentLibrary(w);
%% Run sequence
Playlist = awg.WavesetExtractPlaylistStruct(waveset);
awg.SeqRun(PlayList);

%% Read Data
% Sequence of 10 segments
cardparams.segments=length(w.playlist);
card.SetParams(cardparams);
tstep=1/card.params.samplerate;
taxis=(tstep:tstep:card.params.samples/card.params.samplerate)'./1e-6;%mus units

[Idata, Qdata]=card.ReadIandQ(awg,PlayList);

figure()
subplot(1,2,1);
for i=1:cardparams.segments
    plot(taxis,Idata(i,:)+i);hold on;
end
xlabel('Time (\mus)');
title('Inphase');
subplot(1,2,2);
for i=1:cardparams.segments
    plot(taxis,Qdata(i,:)+i);hold on;
end
xlabel('Time (\mus)');
title('Quadrature');

