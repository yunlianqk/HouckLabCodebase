<<<<<<< HEAD
function [yf, Y2]= ghetto_filter_2_Truncate(y, f_cutoff, sampInt)
% Ghetto filter will take a matrix of data, fft, zero out high frequency
% components, ifft in a symmetric way, and return the filtered data.
% yf is bandpass ghetto filter
% yf2 is matlab fir2 filter 

L = size(y,1);
Fs = 1/(sampInt);
Y = fft(y, [], 1);
Y1 = Y;
f = Fs/2*linspace(0,1,L/2+1);
% Convert cutoff-frequency to index.
cut = 1;
while cut < length(f)-1 && f(cut) < f_cutoff
    cut = cut+1;
end
if cut == length(f) - 1
    display('Cannot do this digital filter');
else
%     Y1(cut+1:end-cut,:)=zeros(size(Y,1)-2*cut, size(Y,2));
%       Y2(1:cut,:) = Y1(1:cut,:);
      Y2(cut+1:2*cut,:) = Y1(end-cut+1:end,:);
%       Y2=Y1;
end
yf=ifft(Y2,[],1);
=======
function [yf, Y2]= ghetto_filter_2_Truncate(y, f_cutoff, sampInt)
% Ghetto filter will take a matrix of data, fft, zero out high frequency
% components, ifft in a symmetric way, and return the filtered data.
% yf is bandpass ghetto filter
% yf2 is matlab fir2 filter 

L = size(y,1);
Fs = 1/(sampInt);
Y = fft(y, [], 1);
Y1 = Y;
f = Fs/2*linspace(0,1,L/2+1);
% Convert cutoff-frequency to index.
cut = 1;
while cut < length(f)-1 && f(cut) < f_cutoff
    cut = cut+1;
end
if cut == length(f) - 1
    display('Cannot do this digital filter');
else
%     Y1(cut+1:end-cut,:)=zeros(size(Y,1)-2*cut, size(Y,2));
%       Y2(1:cut,:) = Y1(1:cut,:);
      Y2(cut+1:2*cut,:) = Y1(end-cut+1:end,:);
%       Y2=Y1;
end
yf=ifft(Y2,[],1);
>>>>>>> fcfd5e9cf561fc8f7ca51bf628e9d0c6f4f94fdd
end