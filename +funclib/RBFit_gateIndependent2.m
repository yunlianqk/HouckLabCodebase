function  result = RBFit_gateIndependent2(xaxis, data, varargin)
% Exponential fit assuming gate independent error model
% See Easwar's PRL 106, 180504
% In this version data is a all of the normalized sequences (ampNormValues) , to make the full plot
% axis is # of cliffords, experimentObject.sequenceLengths
    
    % process ampNormValues into probability of still being in ground state
    ydata = 1-data;
    if isvector(ydata)
        ymean = ydata;
    else
        ymean = mean(ydata);
    end
    
    



    % Construct initial guess for parameters
    offset0 = ymean(end);
    amp0 = ymean(1)-ymean(end);
    p0 = .98;
    beta0 = [offset0, amp0, p0];
    % Fit data
    coeff = nlinfit(xaxis, ymean, @gateIndFit, beta0);
    result.offset = coeff(1);
    result.amp = coeff(2);
    result.p = coeff(3);
    result.avgGateError = 1 - result.p - (1-result.p)/2;
    result.avgGateFidelity = 1-result.avgGateError;
    
    % Plot original and fitted data
    xaxis_dense = linspace(xaxis(1), xaxis(end), 1000);
    Y = gateIndFit(coeff, xaxis_dense);
    
    if ~isempty(varargin) && ishandle(varargin{1})
        ax = varargin{1};
    else
        ax = gca;
    end
    
    plot(xaxis,ydata,'.','color',[.8 .8 .8],'markersize',10)
    hold(ax,'on')
    plot(xaxis,ymean,'r.','markersize',20)
    plot(xaxis_dense,Y,'k')
    axis([0 xaxis(end) .4 1])
    hold(ax,'off')
    title(['Avg. Gate Fidelity: ' num2str(result.avgGateFidelity)])
    xlabel('Clifford Sequence Length','interpreter','latex','fontsize',13)
    ylabel('P$$|0>$$','interpreter','latex','fontsize',13)
end

function y = gateIndFit(beta, x)
    offset = beta(1);
    amp = beta(2);
    p = beta(3);
    y = offset+amp*p.^(x);
end


