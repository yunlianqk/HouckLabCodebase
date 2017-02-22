%% Add class definition files to PATH
run(['..', filesep(), 'setpath.m']);
%% Open card
address = 'PXI7::4::0::INSTR';  % PXI address
card = U1082ADigitizer(address);
%% Set parameters
cardparams = paramlib.acqiris();
cardparams.fullscale = 0.1;
cardparams.offset = 0;
cardparams.sampleinterval = 1e-9;
cardparams.samples = 10000;
cardparams.averages = 30000;
cardparams.segments = 1;
cardparams.delaytime = 1e-6;
cardparams.couplemode = 'DC';
cardparams.trigPeriod = 50e-6;

card.SetParams(cardparams);

% Time axis in us
timeaxis = (0:card.params.samples-1)*card.params.sampleinterval/1e-6;
%% Acquire data
[Idata, Qdata] = card.ReadIandQ();
% Plot data
figure(1);
subplot(2,1,1);
plot(timeaxis, Idata);
title('In-phase');
ylabel('V_I (V)');
subplot(2,1,2);
plot(timeaxis, Qdata);
title('Quadrature');
ylabel('V_Q (V)');
xlabel('Time (\mus)');
