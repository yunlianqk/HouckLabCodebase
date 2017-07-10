function  [lambda, freq,mse,lambdaErr,freqErr] = ExpCosFit(axis, data, varargin)
% Exponentially decaying cosine fit
%this function does not work well when there is only 1 cycle
% Construct initial guess for parameters
datamax = max(data);
datamin = min(data);
amp_guess = (datamax - datamin)/2;
offset_guess = (datamax+datamin)*.5;
   
% Find local extrema in data
[peak, peakloc] = findpeaks(data, axis);
[dip, diploc] = findpeaks(-data, axis);
dip = -dip;
% Remove extrema due to noise in data
peakloc = peakloc(peak > offset_guess);
diploc = diploc(dip < offset_guess);
peak = peak(peak > offset_guess);
dip = dip(dip < offset_guess);

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

% Guess frequency
[freqpeak, freqpeakloc] = findpeaks(P1,f);
freq_guess = freqpeakloc(freqpeak==max(freqpeak)); %in MHz
%     freq_guess = 0.5/abs(peakloc(1)- diploc(1));
try 
    lambda_guess = -(peakloc(1)-peakloc(end)) ...
    /log((peak(1)-offset_guess)/(peak(end)-offset_guess));
catch
    lambda_guess=1;
end    
beta0 = [amp_guess, lambda_guess, offset_guess, freq_guess, 0];
% Fit data
lb=[0.5*amp_guess,0.2,datamin,max(freq_guess-8,0),0]; %lambda in us
ub=[1.5*amp_guess,40,datamax,freq_guess+8,2*pi];
options = optimoptions('lsqcurvefit','TolFun',1e-6);
try
%     [coeff,~,~,~,mse] = nlinfit(axis, data, @ExpCos_beta, beta0);
    [coeff1,mse1,resid1,~,~,~,J1]=lsqcurvefit( @ExpCos_beta,beta0,axis, data,lb,ub,options );
catch
    coeff1=zeros(1,5);
    mse1=100; % high number
end
% repeat with phase offset pi
beta0(5)=pi;
try
%     [coeff,~,~,~,mse] = nlinfit(axis, data, @ExpCos_beta, beta0);
    [coeff2,mse2,resid2,~,~,~,J2]=lsqcurvefit( @ExpCos_beta,beta0,axis, data,lb,ub,options );
catch
    coeff2=zeros(1,5);
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
    ci=[zeros(5,1),ones(5,1)*100];
end    

lambda = coeff(2);
lambdaErr=diff(ci(2,:))/2;
freq = coeff(4);
freqErr=diff(ci(4,:))/2;
% Plot original and fitted data
axis_dense = linspace(axis(1), axis(end), 1000);
Y = ExpCos_beta(coeff, axis_dense);

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

function y = ExpCos_beta(beta, x)
amp = beta(1);
lambda = beta(2);
offset = beta(3);
fringefreq = beta(4);
phaseoffset = beta(5);
y = offset+(amp*exp(-x/lambda).*cos(2*pi*fringefreq*x+phaseoffset));
end


