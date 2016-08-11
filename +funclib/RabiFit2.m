function  newAmplitude = RabiFit2(axis, data, varargin)
% Fit sin^2 function - for explib.  doesn't use an offset
% use sqrt(Power) as data.  Amplitude of pulse for axis

    % Construct initial guess for parameters 
    [peak, index] = max(abs(data));
    amp_guess = peak;
    freq_guess = pi*(1/axis(index))/2;
    beta0 = [amp_guess, freq_guess];
    % Fit data
    coeff = nlinfit(axis, data, @rabi, beta0);
    theta = coeff(2)*axis(round(length(axis)/2));
    newAmplitude = pi/(2*coeff(2));
    % Plot original and fitted data
    axis_dense = linspace(axis(1), axis(end), 1000);
    Y = rabi(coeff, axis_dense);
    
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

function y = rabi(beta, x)
    amp = beta(1);
    freq = beta(2);
    y = amp*sin(freq*x).^2;
end


