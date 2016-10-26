%% waveform generation worksheet
% for generating rbsequence waveforms for playing with M8195a AWG

%% generate sequences
rb=RBExperiment();

%% pick sequence, get basebands, modulate, and plot
seq=rb.sequences(3);
samplingRate=64e9;
tAxis=[0:(1/samplingRate):1e-6-1/samplingRate];
tStop=900e-9;
[iB, qB]=seq.uwWaveforms(tAxis,tStop);
iM=iB.*cos(2*pi*5e9*tAxis);
qM=qB.*sin(2*pi*5e9*tAxis);
figure();plot(tAxis,iM,'b',tAxis,qM,'r')

%% combine and plot final waveform

final = iM+qM;
figure();
plot(tAxis,final,'k',tAxis,iM,'b',tAxis,qM,'r')

%% save to mat file for filtering and uploading

save('C:\waveforms\test')