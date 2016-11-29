function  result = ExpFit3(axis, data, varargin)
% Exponential fit

    % Construct initial guess for parameters
    offset_guess = data(end);
    amp_guess = data(1)-data(end);
    [~, index] = min(abs(data - data(1) - amp_guess*(exp(-1)-1)));
    lambda_guess = axis(index); % should make it easier for nonuniform fits
    beta0 = [amp_guess, lambda_guess,offset_guess];
    
    % Fit data
    [coeff,R,J,CovB,MSE,ErrorModelInfo] =  nlinfit(axis, data, @Exp_beta, beta0);
    result.amp=coeff(1);
    result.lambda=coeff(2);
    result.offset=coeff(3);
    result.R=R;
    result.J=J;
    result.CovB=CovB;
    result.MSE=MSE;
    result.ErrorModelInfo=ErrorModelInfo;
    
    % Plot original and fitted data
    axis_dense = linspace(axis(1), axis(end), 1000);
    Y = Exp_beta(coeff, axis_dense);
    
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

function y = Exp_beta(beta, x)
    amp = beta(1);
    lambda = beta(2);
    offset = beta(3);
    y = offset+amp*exp(-x/lambda);
end


