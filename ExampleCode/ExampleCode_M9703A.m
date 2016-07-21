address='PXI0::CHASSIS1::SLOT2::FUNC0::INSTR'; % PXI address
card=M9703ADigitizer(address);  % create object
%% Set card parameters
cardparams=paramlib.m9703a();   %default parameters

cardparams.samplerate=1.6e9;   % Hz units
cardparams.samples=1.6e9*1e-6;    % samples for a single trace
cardparams.averages=2000;  % software averages=number of traces acquired
cardparams.segments=1; % segments>1 => sequence mode in readIandQ
cardparams.fullscale=1; % in units of V, IT CAN ONLY TAKE VALUE:1,2, other values will give an error
cardparams.offset=0;    % in units of volts
cardparams.coupledmode=1; % 1= 50hm DC
cardparams.enabled=true;
cardparams.delaytime=5e-6; % Delay time from trigger to start of acquistion, units second
cardparams.ChI='Channel1';
cardparams.ChQ='Channel2';
cardparams.TrigSource='External1'; %TRG1 input
cardparams.TrigType='AgMD1TriggerEdge';
cardparams.TrigLevel=0.5; %Trigger level in units of Volts
cardparams.TrigPeriod=10e-3; % ms units

% Update parameters and setup acquisition and trigerring 
card.SetParams(cardparams);
%% Get parameters from digitizer hardware
card.GetParams()
%% Read I and Q for - single averaged segment 
tstep=1/card.params.samplerate;
taxis=(tstep:tstep:card.params.samples/card.params.samplerate)'./1e-6;%mus units

[Idata, Qdata]=card.ReadIandQ();

figure()
subplot(1,2,1); plot(taxis, Idata); xlabel('Time (\mus)'); ylabel('In phase homod voltage (V)')
subplot(1,2,2); plot(taxis, Qdata); xlabel('Time (\mus)'); ylabel('Quadrature homod voltage (V)')
%% Read I and Q - averaged sequence mode
% Sequence of 10 segments
cardparams.segments=10;
card.SetParams(cardparams);

[Idata, Qdata]=card.ReadIandQ();

figure()
subplot(1,2,1); imagesc((1:cardparams.segments),taxis,Idata);xlabel('Time (\mus)'); ylabel('Segment number')
subplot(1,2,2); imagesc((1:cardparams.segments),taxis,Qdata);xlabel('Time (\mus)'); ylabel('Segment number')