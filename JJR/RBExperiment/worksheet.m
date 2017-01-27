% DirectSynthesis WorksheetV2 
% using refactored code to try to automate calibrations.

%%%%%%%%%%%%%%% INTIALIZATIONS
% CHECKLIST
% m8195a SFP open, with the following setting adjustments
%   - Clock tab: routing to Ref clock in(connected to the Rb clk)
%   - Output tab: chan 1V amp, Ch2(LO) 200mV amp (don't forget warm amp!)
%                 ch3(marker) 1V amp +0.5V offset
%   - Trigger tab: Trigger/Gate, Advance Event -> Trigger In

%% initialize awg 
cd 'C:\Users\newforce\Documents\GitHub\HouckLabMeasurementCode'
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
% cardparams.samples=1.6e9*6.25e-6;    % samples for a single trace
cardparams.samples=round(1.6e9*4.5e-6);    % samples for a single trace
% cardparams.samples=round(1.6e9*1.25e-6);    % samples for a single trace
%cardparams.samples=1100;    % samples for a single trace
% cardparams.averages=100;  % software averages PER SEGMENT
% cardparams.averages=200;  % software averages PER SEGMENT
cardparams.averages=10;  % software averages PER SEGMENT
% cardparams.averages=1;  % software averages PER SEGMENT
cardparams.segments=2; % segments>1 => sequence mode in readIandQ
cardparams.fullscale=1; % in units of V, IT CAN ONLY TAKE VALUE:1,2, other values will give an error
cardparams.offset=0;    % in units of volts
cardparams.couplemode='DC'; % 'DC'/'AC'
cardparams.delaytime=4e-6; % Delay time from trigger to start of acquistion, units second
cardparams.ChI='Channel1';
cardparams.ChQ='Channel2';
cardparams.trigSource='External1'; % Trigger source
cardparams.trigLevel=0.2; % Trigger level in volts
% cardparams.trigPeriod=401.111e-6; % Trigger period in seconds
% cardparams.trigPeriod=301.111e-6; % Trigger period in seconds
cardparams.trigPeriod=301.111e-6; % Trigger period in seconds
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring 

%% load a previous pulseCal object
winopen('C:\Data')
%% recalibrate (load a pulseCal object from a recent experiment if one doesn't exist in workspace

% pulseCal = explib.Recalibrate(pulseCal, awg, card, cardparams,2)
% time=fix(clock);save(['C:\Data\Calibration_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
%             'cardparams','pulseCal');
pulseCal = explib.RecalibrateContinuous(pulseCal, awg, card, cardparams);
%% old experiments
% x = explib.SweepQubitFrequency();
%x = explib.SweepTransmissionFrequencyWithQubitPulse();
% x = explib.SweepTransmissionFrequency();
% x = explib.SweepQubitSigma();
x = explib.SweepTransmissionPower();
cardparams.averages=10;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring 
x.runExperimentM8195A(awg,card,cardparams);

%% Load an experiment
clear x
% x = explib.X180RabiExperiment(pulseCal)
% x = explib.T1Experiment(pulseCal)
% x = explib.SingleShotHistograms(pulseCal);
% x = explib.SingleShotReadoutFidelity_v2(pulseCal,100000,100,1);
% x = explib.T2Experiment();
% x = explib.HahnEcho(pulseCal);
% x = explib.HahnEchoNthOrder(pulseCal);
% x = explib.SweepTransmissionFrequencyWithQubitPulse_v2(pulseCal)
% x = explib.SweepW12Frequency(pulseCal);
% x = explib.T2Spectroscopy(pulseCal);
% x = explib.X90AmpCal(pulseCal);
% x = explib.RBExperiment(pulseCal);
% x = explib.X180AmpCal(pulseCal,0:1:20,20);
% x = explib.X90AmpCal(pulseCal,0:2:40,10);
% x = explib.X180RabiExperiment(pulseCal)
stepSize = .1e-6; steps = 50; start = 50e-9;
durationList=start:stepSize:stepSize*steps+start;
durationList(end)
x = explib.RabiDecay_v2(pulseCal,durationList,0,10);
% x = explib.RotaryEcho(pulseCal)
% x = explib.RBExperimentV2(pulseCal);

cardparams.averages=200;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring 
tic; playlist = x.directDownloadM8195A(awg); toc
% Run an experiment
tic; time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist); toc
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');

%% Run repeat RB experiments
testnum=0;
while 1
    testnum=testnum+1;
    tic; time=fix(clock);
    clear pvals result x ampNormValues
    x=explib.RBExperimentV2(pulseCal);
    numSequences = 50;
    for ind=1:numSequences
        display(['RBSequence ' num2str(ind) ' running'])
        x=explib.RBExperimentV2(pulseCal);
        playlist = x.directDownloadM8195A(awg);
        result = x.directRunM8195A(awg,card,cardparams,playlist);
        toc
        pvals(ind,:)=result.Pint;
        ampNormValues(ind,:)=result.AmpNorm;
        
        figure(144)
        subplot(1,2,1)
        imagesc(pvals(1:ind,:));
        title([x.experimentName num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))])
        subplot(1,2,2)
        rbFitResult = funclib.RBFit_gateIndependent2(result.xaxisNorm,ampNormValues);
        %     plot(ampNormValues')
        %     title([num2str(ind) ' of ' num2str(numSequences) 'sequences'])
        save(['C:\Data\FullRBExperiment_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
            'x', 'awg', 'cardparams', 'numSequences', 'pvals','ampNormValues','result','rbFitResult');
    end
    rbRepeat(testnum)=rbFitResult.avgGateFidelity;
    figure(62)
    plot(rbRepeat)
end
%% Run repeat RB experiments with calibrations in between
tic; time=fix(clock);
clear pvals result x ampNormValues
x=explib.RBExperiment(pulseCal);
numSequences = 50;
for ind=1:numSequences
    % recalibrate
    if ~mod(ind,5)
        pulseCal = explib.Recalibrate(pulseCal, awg, card, cardparams);
    end
    display(['RBSequence ' num2str(ind) ' running'])
    cardparams.averages=50;
    card.SetParams(cardparams);
    x=explib.RBExperiment(pulseCal);
    playlist = x.directDownloadM8195A(awg);
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    toc
    pvals(ind,:)=result.Pint;
    ampNormValues(ind,:)=result.AmpNorm;

    figure(144)
    subplot(1,2,1)
    imagesc(pvals(1:ind,:));
    title([x.experimentName num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))])
    subplot(1,2,2)
    rbFitResult = funclib.RBFit_gateIndependent2(result.xaxisNorm,ampNormValues);
%     plot(ampNormValues')
%     title([num2str(ind) ' of ' num2str(numSequences) 'sequences'])
    save(['C:\Data\FullRBExperimentWithCal_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'numSequences', 'pvals','ampNormValues','result');
end





