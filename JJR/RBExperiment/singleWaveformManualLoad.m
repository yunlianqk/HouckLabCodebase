
t=0:1/32e9:1e-6; 
freq=4.75e9;

mypulse=pulselib.singleGate('X180');
mypulse.dragAmplitude=1;
mypulse.amplitude=0;


[ip qp]=mypulse.uwWaveforms(t,.5e-6);

% Y = (ip.*sin(2*pi*freq*t));
Y=(ip.*sin(2*pi*freq*t)+qp.*cos(2*pi*freq*t));

XDelta=1/32e9;

Y(1000:5000)=ones(1,4001);

figure();plot(t,Y)
save('C:\Data\testPulse.mat','XDelta','Y')

%%

wf2= iqcorrection(Y,32e9);
figure();plot(t,real(wf2),t,imag(wf2))
%%
figure();plot(t,real(wf2)+imag(wf2))

%%
figure();plot(t,real(wf2).*cos(2*pi*freq*t))
%%
Y = real(wf2)+imag(wf2);
save('C:\Data\testPulse.mat','XDelta','Y')