function [yf, Y2]= lessghetto_filter(y, sigma, sampInt)
% Ghetto filter will take a matrix of data, fft, 
% applies a gaussian filter of width sigma in timesteps by convolution
% in fourier domain, and then does ifft
% and return the filtered data.
% yf is bandpass ghetto filter
% yf2 is matlab fir2 filter

L = size(y,1);
Fs = 1/(sampInt);
% Y = fft(y, [], 1);
Y = fft(y);
Y1 = Y;
f = Fs/2*linspace(0,1,L/2+1);
% Convert cutoff-frequency to index.
cut = 1;
% while cut < length(f)-1 && f(cut) < f_cutoff
%     cut = cut+1;
% end
if cut == length(f) - 1
    display('Cannot do this digital filter');
else
    ys_f = Y1;
    
    xs = linspace(0, 10, L); %fake x axis
    deltax = xs(2)-xs(1);
    
    
%     sigma2 = sigma*max(xs);
    sigma2 = sigma*deltax;
    xs_shifted = xs - mean(xs);
    gau2 = 1/(sigma2 * sqrt(2*pi))*exp(-xs_shifted.^2/(2*sigma2^2))*deltax; %normalized gaussian
    gau2_k = fft(gau2);
    
    filt2_f = ys_f.*gau2_k'; %convolve
    
    filt2 = ifft(filt2_f); %return to real space
    
    
    
%     figure(777)
%     clf()
%     subplot(2,1,1)
%     hold on
%     plot(abs(gau2)*mean(y)*40, 'g')
%     % plot(abs(filt1), 'b')
%     plot(abs(filt2), 'r')
%     plot(real(y), 'b')
%     hold off
%     title('filtered (real space)')
% 
%     subplot(2,1,2)
%     hold on
%     % plot(abs(filt1_f), 'b')
%     plot(abs(gau2_k), 'g')
%     plot(abs(ys_f), 'k')
%     % plot(abs(filt2_f), 'r')
%     hold off
%     title('filtered (momentum space)')
%     
    
end
% yf=ifft(Y2,[],1);
yf = filt2;
Y2 = ys_f;

% yf = Y2;
end