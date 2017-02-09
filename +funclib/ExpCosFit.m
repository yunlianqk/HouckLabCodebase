function  [lambda, freq] = ExpCosFit(axis, data, varargin)
% Exponentially decaying cosine fit

    % Construct initial guess for parameters
    datamax = max(data);
    datamin = min(data);
    amp_guess = datamax - datamin;
    offset_guess = (datamax+datamin)*.5;
    phaseoffset = 0;
    
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
    freq_guess = 0.5/abs(peakloc(1)- diploc(1));
    lambda_guess = -(peakloc(1)-peakloc(end)) ...
                   /log((peak(1)-offset_guess)/(peak(end)-offset_guess));
    beta0 = [amp_guess, lambda_guess, offset_guess, freq_guess, phaseoffset];
    % Fit data
    coeff = nlinfit(axis, data, @ExpCos_beta, beta0);
    lambda = coeff(2);
    freq = coeff(4);
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


