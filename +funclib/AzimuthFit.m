function  newAzimuth = AzimuthFit(axis, data, varargin)
% Fit -cos function for azimuth vs amplitude

% free parameters are offset, amplitude, frequency, and phase
% outputs the azimuthal angle producing a cosine argument of pi/4

    % Construct initial guess for parameters 
    [dataMax, maxInd] = max(data);
    [dataMin, minInd] = min(data);
    offset_guess = dataMin;
    amp_guess = dataMax-dataMin;
    freq_guess = 0.5/abs(axis(maxInd)-axis(minInd));
    phase_guess = 0;
    beta0 = [offset_guess, amp_guess, freq_guess, phase_guess];
    % Fit data
    Lbound =[0, 0, 0, -pi];   % lower bounds on coeff
    Ubound =[1, 2*amp_guess, abs(freq_guess), pi];    % upper bounds on coeff
    opts = optimset('Display', 'off'); % suppress fit message 
    coeff = lsqcurvefit(@drag, beta0, axis, data, Lbound, Ubound, opts);

    % Plot original and fitted data
    axis_dense = linspace(axis(1), axis(end), 10000);
    Y = drag(coeff, axis_dense);
    [~, fitMinIndex] = min(Y);
    [~, fitMaxIndex] = max(Y);
    azIndex = round(mean([fitMinIndex fitMaxIndex]));
    newAzimuth = axis_dense(azIndex);
    
    
    if ~isempty(varargin) && ishandle(varargin{1})
        ax = varargin{1};
    else
        ax = gca;
    end
    plot(ax, axis*(180/pi), data, '.');
    hold(ax, 'on');
    plot(ax, axis_dense*(180/pi), Y, 'r', 'LineWidth', 2);
    plotlib.vline(newAzimuth*(180/pi));
    hold(ax, 'off');
end

function y = drag(beta, x)
    offset = beta(1);
    amp = beta(2);
    freq = beta(3);
    phase = beta(4);
    y = -amp*cos(2*pi*freq*x + phase) + offset;
end