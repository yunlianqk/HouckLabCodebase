clear filti filtq rawi rawq

fprintf(instr.specgen, 'outp 1');
%0/1 means rotation around X/Y axis
PulseSequence = [...
    0 0; 0 0; 0 1; 0 1; 1 0;...
    1 0; 1 1; 1 1; 0 0; 0 0;...
    0 1; 0 1; 1 0; 1 0; 1 1;...
    1 1; 0 0; 0 1; 1 0; 1 1;...
    0 0; 0 0; 0 1; 0 1; 1 0;...
    1 0; 1 1; 1 1];

pi_p = 0.634;
piover2_p = .321;
pi_m = -0.617;
piover2_m = -0.306;
% each element takes values \pm 0, \pm .5, \pm 1
AmplitudeSequence = [...
    pi_p pi_p;    pi_p pi_m;   pi_p pi_p;    pi_p pi_m;   pi_p pi_p;    ...seq
    pi_p pi_m;   pi_p pi_p;    pi_p pi_m;   pi_p piover2_p;   pi_p piover2_m;  ...
    pi_p piover2_p;   pi_p piover2_m;  pi_p piover2_p;   pi_p piover2_m;  pi_p piover2_p;   ...
    pi_p piover2_m;  piover2_p pi_p;   piover2_p pi_p;   piover2_p pi_p;   piover2_p pi_p;   ...
    piover2_p piover2_p;  piover2_p piover2_m; piover2_p piover2_p;  piover2_p piover2_m; piover2_p piover2_p;  ...
    piover2_p piover2_m; piover2_p piover2_p;  piover2_p piover2_m];




nbrExp = length(PulseSequence);
dragamp = 0.13:0.005:0.19;

for countdrag = 1:length(dragamp)
    for counter = 1:nbrExp
        AWG_ArbGaussianPulseGenerator(AWGHandle, AmplitudeSequence(counter,:), PulseSequence(counter,:), dragamp(countdrag),IndAll(49,:));
        [rawi(countdrag,counter,:), rawq(countdrag,counter,:)] = readIandQ(CardParameters);    
    end
end

% fprintf(instr.specgen, 'outp 0');
% [rawi(end+1,:), rawq(end+1,:)] = readIandQ(CardParameters);

filti = mean(rawi(:,:,1400:4000),3);
filtq = mean(rawq(:,:,1400:4000),3);
    
clear counter AmplitudeSequence PulseSequence nbrExp countdrag
    