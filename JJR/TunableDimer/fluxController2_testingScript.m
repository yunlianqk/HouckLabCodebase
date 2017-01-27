clear fc
fc = fluxController2;
EcLeft = 298e6;
EcRight = 298e6;
EjSumLeft = 25.420e9;
EjSumRight = 29.342e9;
fc.leftQubitFluxToFreqFunc = @(x) sqrt(8.*EcLeft.*EjSumLeft.*abs(cos(pi.*x)))-EcLeft;
%  fc.leftQubitFreqToFluxFunc = @(x) acos(((x-EcLeft).^2)./(8.*EcLeft.*EjSumLeft))./pi;
fc.rightQubitFluxToFreqFunc = @(x) sqrt(8.*EcRight.*EjSumRight.*abs(cos(pi.*x)))-EcRight;
% fc.rightQubitFreqToFluxFunc = @(x) acos(((x-EcRight).^2)./(8.*EcRight.*EjSumRight))./pi;
%%
fc.calculateLeftQubitFrequency(0)
fc.calculateRightQubitFrequency(0)
% fc.calculateLeftQubitFluxFromFrequency(5.7e9)
fc.calculateLeftQubitFrequency(0.15)
fc.calculateRightQubitFrequency(-0.2)
%%
fc.calculateLeftQubitFluxFromFrequency(5.8585e9)
fc.calculateRightQubitFluxFromFrequency(5.8585e9)