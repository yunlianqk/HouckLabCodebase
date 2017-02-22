%% Add class definition files to PATH
run(['..', filesep(), 'setpath.m']);
%% Create gate objects
% pi pulse along X-axis
X180 = pulselib.singleGate('X180');
X180.sigma = 8e-9;
X180.cutoff = 4*X180.sigma;
X180.dragAmplitude = 0.2;
% pi/2 pulse along Y-axis
Y90 = pulselib.singleGate('Y90');
Y90.sigma = 15e-9;
Y90.cutoff = 6*Y90.sigma;
Y90.dragAmplitude = -0.1;
% 150 ns delay
delayGate = pulselib.delay(150e-9);
%% Plot single gate
X180.draw();
%% Creat sequence and add gates to sequence
gateSeq = pulselib.gateSequence();
gateSeq.append(X180);
gateSeq.append(delayGate);
gateSeq.append(Y90);  % gateSeq now contains X180 and Y90
                      % with 150 ns of delay in between
%% Manipulate sequence
gateSeq.append([X180, X180]);  % append two X180's to the end of sequence
gateSeq.insert(2, Y90);  % insert Y90 as the 2nd gate of sequence
gateSeq.pop([2, 5:6]);  % remove gate 2, 5 and 6 from sequence
gateSeq.append({X180, delayGate});  % use cell array for gate objects of different classes
gateSeq.pop([4, 5]);
%% Plot sequence
gateSeq.draw();
%% Generate waveforms
taxis = 0:0.8e-9:320e-9;  % Time axis with sampling interval 0.8 ns
tstart = 20e-9;  % Pulse sequence starts at t = 20 ns
% Call uwWaveforms method to get waveforms
[iWaveform, qWaveform] = gateSeq.uwWaveforms(taxis, tstart);

figure(1);
plot(taxis/1e-9, iWaveform, 'b', taxis/1e-9, qWaveform, 'r');
axis([taxis(1)/1e-9, taxis(end)/1e-9, -0.3, 1.1]);
xlabel('Time (ns)');
ylabel('Amplitude');
legend('I', 'Q');
%% Using pulsCal
gatelist = {'X180', 'measurement'};  % List of gate names
pulseCal = paramlib.pulseCal();  % Create pulseCal object
gateSeq = pulselib.gateSequence();  % Create gateSequence object
taxis = 0:0.8e-9:700e-9;  % Time axis
tstart = 20e-9;  % Sequence start time

% Set up parameters in pulseCal
pulseCal.sigma = 8e-9;
pulseCal.cutoff = 4*pulseCal.sigma;
pulseCal.X180Amplitude = 1.0;
pulseCal.X180DragAmplitude = 0.2;
pulseCal.cavityAmplitude = 0.8;
pulseCal.measDuration = 0.5e-6;

% Generate gate objects by passing their names to pulseCal
% Then append them to gateSeq
for gate = gatelist
    gateSeq.append(pulseCal.(gate{:}));
end
% Insert delay between two gates
gateSeq.insert(2, pulselib.delay(50e-9));
% Generate waveforms for AWG
[iWaveform, qWaveform] = gateSeq.uwWaveforms(taxis, tstart);

figure(2);
plot(taxis/1e-9, iWaveform, 'b', taxis/1e-9, qWaveform, 'r');
axis([taxis(1)/1e-9, taxis(end)/1e-9, -0.3, 1.1]);
xlabel('Time (ns)');
ylabel('Amplitude');
legend('I', 'Q');