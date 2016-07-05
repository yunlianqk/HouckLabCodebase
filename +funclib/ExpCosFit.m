function  [lambda, freq] = ExpCosFit(axis, data, varargin)
% Exponentially decaying cosine fit

    % Construct initial guess for parameters
    offset_guess = (max(data)+min(data))*.5;
    amp_guess = max(data)-min(data);
    phaseoffset = 0;
    % Use fft to guess fringefreq
    fAxis = linspace(0, 1/(axis(2)-axis(1)), length(axis));
    spec = fft(data);
    [~, index] = max(spec(2:floor(length(axis)/2)));
    fringefreq_guess = fAxis(index);
    index = round(2/fringefreq_guess/(axis(2)-axis(1)));
    lambda_guess = abs(axis(index)/log(1-(data(1)-data(index))/amp_guess));
    if lambda_guess < 0
        display('Guess for decay is negative. Fit will not work');
    end
    beta0 = [amp_guess, lambda_guess, offset_guess, fringefreq_guess, phaseoffset];
    % Fit data
    coeff = nlinfit(axis, data, @ExpCos_beta, beta0);
    lambda = coeff(2);
    freq = coeff(4)/(2*pi);
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


