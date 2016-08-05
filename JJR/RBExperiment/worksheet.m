% script for running transmission scan with M8195A and M9703A
% CHECKLIST
% m8195a SFP open, with the following setting adjustments
%   - Clock tab: routing to Ref clock in(connected to the Rb clk)
%   - Output tab: chan 1V amp, Ch2(LO) 200mV amp (don't forget warm amp!)
%                 ch3(marker) 1V amp +0.5V offset
%   - Trigger tab: Trigger/Gate, Advance Event -> Trigger In

%% initialize awg 
addpath('C:\Users\newforce\Documents\GitHub\HouckLabMeasurementCode');
% Choose settings in IQ config window (M8195A_2ch_mrk,ext ref clk)-> press Ok
% Import FIR filter -> press Ok
awg = M8195AWG();
%% initialize digitizer
address='PXI0::CHASSIS1::SLOT2::FUNC0::INSTR'; % PXI address
card=M9703ADigitizer(address);  % create object

%% Set card parameters
cardparams=paramlib.m9703a();   %default parameters

cardparams.samplerate=1.6e9;   % Hz units
cardparams.samples=1.6e9*6e-6;    % samples for a single trace
cardparams.averages=20;  % software averages PER SEGMENT
cardparams.segments=2; % segments>1 => sequence mode in readIandQ
cardparams.fullscale=1; % in units of V, IT CAN ONLY TAKE VALUE:1,2, other values will give an error
cardparams.offset=0;    % in units of volts
cardparams.couplemode='DC'; % 'DC'/'AC'
cardparams.delaytime=4e-6; % Delay time from trigger to start of acquistion, units second
cardparams.ChI='Channel1';
cardparams.ChQ='Channel2';
cardparams.trigSource='External1'; % Trigger source
cardparams.trigLevel=0.2; % Trigger level in volts
cardparams.trigPeriod=300e-6; % Trigger period in seconds

% Update parameters and setup acquisition and trigerring 
card.SetParams(cardparams);

%%
clear x;
% x=explib.SweepTransmissionFrequency();
% x=explib.SweepTransmissionPower();
% x=explib.SweepQubitFrequency();
% x=explib.RabiExperiment();
% x=explib.SweepQubitSigma();
x=explib.T1Experiment();
% x=explib.T2Experiment();
% x=explib.X90AmpCal();
% w=x.genWaveset_M8195A();
% w.drawSegmentLibrary()
% x=explib.T1Experiment();
% result = x.runExperimentM8195A(awg,card,cardparams);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist)
%%
tic
result = x.directRunM8195A(awg,card,cardparams,playlist)
toc
%% t1 repeat
clear lambda result
for ind=1:200
    tic
    result = x.directRunM8195A(awg,card,cardparams,playlist)
    toc
    pvals(ind,:)=result.Pint;
    lamda(ind)=result.lambda;
    figure(166)
    plot(lamda)
end

%% t2 detuning scan - rerun t2 measurement with multiple detunings
clear pvals result
delta = linspace(-.2e6,.2e6,41);
pvals=zeros(length(delta),101);
for ind=1:length(delta)
    tic
    x=explib.T2Experiment();
    x.qubitFreq=4.772869998748302e9 + delta(ind);
    playlist = x.directDownloadM8195A(awg);
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    toc
    pvals(ind,:)=result.Pint;
    figure(166)
    imagesc(pvals(1:ind,:));
    
end



