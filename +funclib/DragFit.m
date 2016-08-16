function  newDragAmplitude = DragFit(axis, data, varargin)
% Fit -cos function for drag vs amplitude - for explib.  
% free parameters are offset, amplitude, frequency, and phase
% outputs the amplitude corresponding to the cosine minimum nearest zero

    % Construct initial guess for parameters 
    [dataMax, maxInd] = max(data);
    [dataMin, minInd] = min(data);
%     offset_guess = dataMin;
    offset_guess = 0;
    amp_guess = dataMax-dataMin;
    freq_guess = 2*abs(axis(maxInd)-axis(minInd));
    phase_guess = 0;
    beta0 = [offset_guess amp_guess freq_guess phase_guess];
    % Fit data
    coeff = nlinfit(axis, data, @drag, beta0);
    freqFit=coeff(3);
    phaseFit=coeff(4);
    newDragAmplitude = -1*phaseFit/(2*pi*freqFit);
%     newAmplitude = pi/(2*coeff(2));
    % Plot original and fitted data
    axis_dense = linspace(axis(1), axis(end), 1000);
    Y = drag(coeff, axis_dense);
    
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

function y = drag(beta, x)
    offset=beta(1);
    amp = beta(2);
    freq = beta(3);
    phase = beta(4);
    y = amp*((1-cos(2*pi*freq*x + phase))/2)+offset;
end


