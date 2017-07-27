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
    % %     Y1(cut+1:end-cut,:)=zeros(size(Y,1)-2*cut, size(Y,2));
    % %       Y2(1:cut,:) = Y1(1:cut,:);
    
    %       Y2(cut+1:2*cut,:) = Y1(end-cut+1:end,:);
    
    % %       Y2=Y1;
    
    %     %cheating filter
    %     xs = linspace(-1,1,L);
    %     sigma = 0.01;
    %     gau = 1/(sigma * sqrt(2*pi))*exp(-xs.^2/(2*sigma^2));
    %     gau_k = fftshift(gau);
    %
    %     Y2 = Y1'.*gau_k;
    
    
    xs = linspace(0, 10, L);
    
    ys_f = Y1;
    
    
    % sigma = 0.01;
    % gau = 1/(sigma * sqrt(2*pi))*exp(-xs.^2/(2*sigma^2));
    % gau_k = fftshift(gau);
    
    sigma2 = 0.11*max(xs);
    % gau2 = 1/(sigma2 * sqrt(2*pi))*exp(-xs.^2/(2*sigma2^2));
    xs_shifted = xs - mean(xs);
    gau2 = 1/(sigma2 * sqrt(2*pi))*exp(-xs_shifted.^2/(2*sigma2^2));
    gau2_k = fft(gau2);
    
    
    % filt1_f = ys_f.*gau_k;
    filt2_f = ys_f.*gau2_k';
    
    % filt1 = ifft(filt1_f);
    filt2 = ifft(filt2_f);
    
    
end
% yf=ifft(Y2,[],1);
yf = filt2;
Y2 = ys_f;

% yf = Y2;
end