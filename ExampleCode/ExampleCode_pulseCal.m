%% Add class definition files to PATH
run(['..', filesep(), 'setpath.m']);
%% Create and set up a 'pulseCal' object
pulseCal = paramlib.pulseCal();
pulseCal.sigma = 10e-9;
pulseCal.cutoff = 4*pulseCal.sigma;
pulseCal.X180Amplitude = 0.8;
pulseCal.X180DragAmplitude = 0.25;
%% Create gate object
X180 = pulseCal.X180();
display(X180);
%% Create sequence of gates
nameList = {'X180', 'X180', 'X90', 'Y90'};  % List of gate names
pulseCal = paramlib.pulseCal();
gateList = [];

for gate = nameList
    % pulseCal.(gate{:}) converts gate name to gate object
    gateList = [gateList, pulseCal.(gate{:})];
end