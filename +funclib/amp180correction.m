function [ percentage_corr ] = amp180correction( x_axis,y_axis )
   x0 = [0.5,0.10]; %x0(1) goes to 1/2 for perfect x90, x0(2) is the error in rotation
    % x_axis is num of gates
    x = lsqcurvefit(@funclib.amp_error_90, x0, x_axis,y_axis);
    percentage_corr = 1/(1 + x(2)/(pi/2));
    code_error = funclib.amp_error_90(x, x_axis);
    figure()
    plot(x_axis, code_error,x_axis, y_axis )
    legend('corrected','measured')

end

