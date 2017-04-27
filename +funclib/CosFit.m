function  [freq,mse,amp,freqErr] = CosFit(axis, data, varargin)
% Cosine fit
% axis in us and freq_guess in MHz
% Construct initial guess for parameters
datamax = max(data);
datamin = min(data);
amp_guess = (datamax - datamin)/2;
offset_guess = (datamax+datamin)*.5;
phaseoffset = 0;%pi;
% Guess frequency
L=length(axis); %length of signal
T=axis(end)/(L-1); %sampling period
Fs=1/T; %sampling freq
Y=fft(data);%,n);
%calculate double sided spectrum and single sided
P2 = abs(Y/L);
P1 = P2(1:floor(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:floor(L/2))/L;

%%Note: The frequency can sometimes be way off fringe freq, so fft is imp.
% Guess frequency
[freqpeak, freqpeakloc] = findpeaks(P1,f);
freq_guess = freqpeakloc(freqpeak==max(freqpeak)); %in MHz
beta0 = [amp_guess, offset_guess, freq_guess, phaseoffset];
% Restrict the fit to within 20 MHz from freq_guess
lb=[0.5*amp_guess,datamin,max(freq_guess-18,0),0];
ub=[1.5*amp_guess,datamax,freq_guess+18,2*pi];
% Fit data
try
    [coeff1,mse1,resid1,~,~,~,J1] = lsqcurvefit( @Cos_beta,beta0,axis, data,lb,ub );
catch
    coeff1=zeros(1,4);
    mse1=100; % high number
end
% repeat with phase offset pi
beta0(4)=pi;
try
    [coeff2,mse2,resid2,~,~,~,J2] = lsqcurvefit( @Cos_beta,beta0,axis, data,lb,ub );
catch
    coeff2=zeros(1,4);
    mse2=100; % high number
end

if(mse2>=mse1)
    coeff=coeff1;
    mse=mse1;
    resid=resid1;
    J=J1;
else
    coeff=coeff2;
    mse=mse2;
    resid=resid2;
    J=J2;
end  
ci = nlparci(coeff,resid,'jacobian',J);

if(mse==100)
    ci=[zeros(4,1),ones(4,1)*100];
end    
freq = coeff(3);
freqErr=diff(ci(3,:))/2;
amp=coeff(1);
% Plot original and fitted data
axis_dense = linspace(axis(1), axis(end), 1000);
Y = Cos_beta(coeff, axis_dense);

if ~isempty(varargin) && ishandle(varargin{1})
    ax = varargin{1};
else
    ax = gca;
end
plot(ax, axis, data, '.');
hold(ax, 'on');
plot(ax, axis_dense, Y, 'r', 'LineWidth', 2);
hold(ax, 'off');
end

function y = Cos_beta(beta, x)
amp = beta(1);
offset = beta(2);
fringefreq = beta(3);
phaseoffset = beta(4);
y = offset+(amp.*cos(2*pi*fringefreq*x+phaseoffset));
end


