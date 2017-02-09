function  newAmplitude = RabiFit(axis, data, varargin)
% Fit data = offset + amp*sin(freq*axis).^2

    % Guess amplitude
    datamax = max(data);
    datamin = min(data);
    amp_guess = datamax - datamin;
    % Find local extrema in data
    [peak, peakloc] = findpeaks(data, axis);
    [dip, diploc] = findpeaks(-data, axis);
    dip = -dip;
    % Remove extrema due to noise in data
    peakloc = peakloc(peak > datamax -  amp_guess/10);
    diploc = diploc(dip < datamin + amp_guess/10);
    % Guess offset
    if data(1) > (datamax + datamin)/2
        amp_guess = -amp_guess;
        offset_guess = datamax;
    else
        offset_guess = datamin;
    end
    % Guess frequency
    freq_guess = pi/2/abs(peakloc(1)- diploc(1));
    % Fit data
    beta0 = [amp_guess, freq_guess, offset_guess];
    Lbound = [min(0.5*amp_guess, 1.5*amp_guess), ...
              0.5*freq_guess, ...
              offset_guess-0.2*abs(amp_guess)];
    Ubound = [max(0.5*amp_guess, 1.5*amp_guess), ...
              1.5*freq_guess, ...
              offset_guess+0.2*abs(amp_guess)];
    opts = optimset('Display', 'off'); % suppress fit message 
    coeff = lsqcurvefit(@rabi, beta0, axis, data, Lbound, Ubound, opts);
    % Plot original and fitted data
    axis_dense = linspace(axis(1), axis(end), 1000);
    Y = rabi(coeff, axis_dense);
    [~, index] = max(abs(Y-Y(1)));
	newAmplitude = axis_dense(index);
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
    offset = beta(3);
    y = amp*sin(freq*x).^2 + offset;
end