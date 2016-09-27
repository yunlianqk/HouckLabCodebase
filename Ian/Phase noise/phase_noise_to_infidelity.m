load('phase_noise_data.mat')
w = linspace(1,1e6,646) * 2 * pi;
w = w';
pn = PhaseNoiseBerkN(2:end);
S1z = 1/2 * w.*w .* 10.^(pn/10);
tau = 3e-6;

%% For Ramsey
Gzz = 4 * sin(w * tau/2) .^2;
I = S1z .* Gzz./w.^2/pi;
chi = trapz(w,I);
F = 1/2 * exp(-chi)

%% For spin Echo
Gzz = 16 * sin(w * tau) .^4;
G = Gzz;
I = S1z .* G./w.^2/pi;
chi = trapz(w,I);
F = 1/2 * exp(-chi)

%% For Primitive pi-pulse
Gzz = (w.^2/(w.^2 - (pi/tau).^2) * (exp(1i * w * tau) + 1)).^2;
Gzy = ((1i * w .* (pi/tau))/(w.^2 - (pi/tau).^2) * (exp(1i * w * tau) + 1)).^2;

G = Gzz + Gzy;
I = S1z .* G./w.^2/pi;
chi = trapz(w,I);
F = 1/2 * exp(-chi)