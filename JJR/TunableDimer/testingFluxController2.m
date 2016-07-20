clear fc
fc = fluxController2;

Ec = 298e6;
EjSum = 29.342e9;
fc. rightQubitFluxToFreqFunc = @(x) sqrt(8.*Ec.*EjSum.*abs(cos(pi.*x)))-Ec;

fluxVal = .5;
fc.calculateRightQubitFrequency(fluxVal);
%%
freqVal = 8e9;
fc.calculateRightQubitFluxFromFrequency(freqVal)
