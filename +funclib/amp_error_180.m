function [ P ] = amp_error_180(x, xdata)
% Fitting function copied from http://journals.aps.org/pra/pdf/10.1103/PhysRevA.93.012301
% Characterizing errors on qubit operations via iterative randomized benchmarking
    P = x(1) + 1/2 * cos(pi/2 + 2* xdata * x(2));
end