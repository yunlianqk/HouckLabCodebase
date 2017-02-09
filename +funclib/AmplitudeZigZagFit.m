function fitResult = AmplitudeZigZagFit(numPiRotations, data, varargin)
% Fit the zigzag for amplitude calibration.  See Sheldon et al. Phys. Rev. A 93, 012301 (2016)
% inputs: 
% numPiRotations - this is the xaxis, should handle amplitude
% calibrations for either pi or pi/2 pulses, so long as the x axis
% corresponds to the number of EFFECTIVE PI PULSES that have been done.
% data - this data should already be normalized relative to qubit excited
% or in the ground state.
% varargin - optional input of an axes handle, if one is given it will plot
% the data with a fit overlayed on it.

    % set initial guess parameters
    offset0 = .5; % for a perfect pi/2 initialization this will be on equator of bloch sphere - i.e. .5
    errorInRadians0 = 0.01; %
    x0 = [offset0 errorInRadians0];
    options = optimset('Display','off');
    x = lsqcurvefit(@amp_error, x0, numPiRotations, data,[],[], options);
    fitResult.offset = x(1);
    fitResult.errorInRadians = x(2);  
    fitResult.updateFactor = 1/(1+x(2)/pi); % multiply old pi pulse amplitude by this factor to find new amplitude.        percentage_corr = 1/(1 + x(2)/(pi/2));

    Y = amp_error(x, numPiRotations);
    
    if ~isempty(varargin) && ishandle(varargin{1})
        ax = varargin{1};
    else
        ax = gca;
    end
    plot(ax, numPiRotations, Y,'LineWidth', 2,'color',[.8 .8 .8],'markersize',12);
    hold(ax, 'on');
    plot(ax, numPiRotations, data, 'k.','LineWidth', 2,'markersize',12);
    plotlib.hline(0)
    plotlib.hline(1)
    hold(ax, 'off');
end

function P = amp_error(x, xdata)
% Some numbers and a sign were changed from the paper to ensure that error corresponded to
% over-rotation in radians.
    offset = x(1);
    errRad = x(2);
    P = offset + .5*(-1).^xdata .*cos(pi/2 - xdata*errRad);
end

