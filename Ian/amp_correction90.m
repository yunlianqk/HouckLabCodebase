function [ percentage_corr ] = amp_correction90( x_axis,y_axis)
    x0 = [0.5,0.050]; %x0(1) goes to 1/2 for perfect x90, x0(2) is the error in rotation
    x = lsqcurvefit(@amp_error, x0, x_axis/2,y_axis);
    percentage_corr = 1/(1 + x(2)/(pi/2));
    figure(111)
    code_error = amp_error(x, x_axis/2);
    plot(x_axis, code_error,x_axis, y_axis )
    legend('predicted','measured')
    title('Amplitude error correction')
end

function [ P ] = amp_error(x, xdata)
% Fitting function copied from http://journals.aps.org/pra/pdf/10.1103/PhysRevA.93.012301
% Characterizing errors on qubit operations via iterative randomized benchmarking
    P = x(1) + 1/2 * (-1).^xdata .*cos(pi/2 + 2* xdata * x(2));
end