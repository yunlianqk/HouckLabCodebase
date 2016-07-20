fc = fluxController2;
Ec = 298e6;
EjSum = 29.342e9;
fc.rightQubitFluxToFreqFunc = @(x) sqrt(8.*Ec.*EjSum.*abs(cos(pi.*x)))-Ec;
fc.rightQubitFreqToFluxFunc = @(x) acos(((x-Ec).^2)./(8.*Ec.*EjSum))./pi;

fc.calculateRightQubitFrequency(0)