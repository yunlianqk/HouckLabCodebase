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
cardparams.samples=1.6e9*6.25e-6;    % samples for a single trace
% cardparams.averages=50;  % software averages PER SEGMENT
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
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring 
%% Create pulseCal object - NOTE: pulseCal objects are VALUE objects not HANDLE objects
pulseCal = paramlib.pulseCal();
% generic qubit pulse properties
pulseCal.qubitFreq = 4.772869998748302e9;
pulseCal.sigma = 4e-9;
pulseCal.cutoff = 4*pulseCal.sigma;
pulseCal.buffer = 4e-9;
% measurement pulse properties
pulseCal.cavityFreq = 10.16578e9;
pulseCal.cavityAmplitude = 0.3;
pulseCal.measDuration = 10e-6; % length of measurement pulse
% waveform properties
pulseCal.startBuffer = 5e-6; % delay after start before qubit pulses can occur
pulseCal.measBuffer = 200e-9; % delay btw final qubit pulse and measurement pulse
pulseCal.endBuffer = 5e-6; % buffer after measurement pulse
pulseCal.samplingRate=32e9;
% acquisition properties
pulseCal.integrationStartIndex = 1; % start point for integration of acquisition card data
pulseCal.integrationStopIndex = 10000; % stoppoint for integration of acquisition card data
pulseCal.cardDelayOffset = 1.5e-6; % time delay AFTER measurement pulse to start acquisition
% USAGE: cardparams.delaytime = experimentObject.measStartTime + acquisition.cardDelayOffset;
% gate specific properties
pulseCal.X90Amplitude =.3354; 
pulseCal.X90DragAmplitude = .044302;
pulseCal.Xm90Amplitude = pulseCal.X90Amplitude;
pulseCal.Xm90DragAmplitude = pulseCal.X90DragAmplitude;
pulseCal.X180Amplitude = .68518;
pulseCal.X180DragAmplitude = .064985;
pulseCal.Xm180Amplitude = pulseCal.X180Amplitude;
pulseCal.Xm180DragAmplitude = pulseCal.X180DragAmplitude;
pulseCal.Y90Amplitude = .33353;
pulseCal.Y90DragAmplitude = -0.039424;
pulseCal.Ym90Amplitude = pulseCal.Y90Amplitude;
pulseCal.Ym90DragAmplitude = pulseCal.Y90DragAmplitude;
pulseCal.Y180Amplitude = .68471;
pulseCal.Y180DragAmplitude = -0.06357;
pulseCal.Ym180Amplitude = pulseCal.Y180Amplitude;
pulseCal.Ym180DragAmplitude = pulseCal.Y180DragAmplitude;

 %% Load an experiment
clear x

% x = explib.X180RabiExperiment(pulseCal);
x = explib.X180DragCal(pulseCal);
% x = explib.X180AmpCal(pulseCal);

% x = explib.X90AmpCal(pulseCal);
% x = explib.X90DragCal(pulseCal);

% x = explib.Y180RabiExperiment(pulseCal);
% x = explib.Y180DragCal(pulseCal);
% x = explib.Y180AmpCal(pulseCal);

% x = explib.Y90AmpCal(pulseCal);
% x = explib.Y90DragCal(pulseCal);

% x = explib.RBExperiment(pulseCal);

% tic; playlist = x.directDownloadM8195A(awg); toc
tic; result = x.directRunM8195A(awg,card,cardparams,playlist); toc

%% Run an experiment
tic; time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);

save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');

%% Run repeat RB experiments
tic; time=fix(clock);
clear pvals result x ampNormValues
x=explib.RBExperiment(pulseCal);
numSequences = 100;
for ind=1:numSequences
    display(['RBSequence ' num2str(ind) ' running'])
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
    save(['C:\Data\FullRBExperiment_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'numSequences', 'pvals','ampNormValues','result');
end





