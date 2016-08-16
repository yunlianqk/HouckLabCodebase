function  result = RBFit_gateIndependent(axis, data, varargin)
% Exponential fit assuming gate independent error model
% See Easwar's PRL 106, 180504

    % Construct initial guess for parameters
    offset0 = data(end);
    amp0 = data(1)-data(end);
%     p0 =  -axis(20)/log(1-(data(1)-data(20))/amp_guess);
    p0 = .98
    beta0 = [offset0, amp0, p0];
    % Fit data
    coeff = nlinfit(axis, data, @gateIndFit, beta0);
    result.offset = coeff(1);
    result.amp = coeff(2);
    result.p = coeff(3);
    result.avgGateError = 1 - result.p - (1-result.p)/2;
    result.avgGateFidelity = 1-result.avgGateError;
    
    % Plot original and fitted data
    axis_dense = linspace(axis(1), axis(end), 1000);
    Y = gateIndFit(coeff, axis_dense);
    
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

function y = gateIndFit(beta, x)
    offset = beta(1);
    amp = beta(2);
    p = beta(3);
    y = offset+amp*p.^(x);
end


