function [ percentage_corr ] = x180_correction( x_axis,y_axis )
    x0 = [0.5,0.010]; %x0(1) goes to 1/2 for perfect x90, x0(2) is the error in rotation
    x = lsqcurvefit(@amp_error_180, x0, x_axis/2,y_axis);
    percentage_corr = 1 - x(2)/(pi/2);
    code_error = amp_error_180(x, x_axis/2);
    
    figure()
    plot(x_axis, code_error,x_axis, y_axis )
    legend('corrected','measured')

end

