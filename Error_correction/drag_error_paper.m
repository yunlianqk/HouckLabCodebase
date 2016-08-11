function [ P ] = drag_error_paper(x, xdata) 
 P = x(1) + 1/2 * cos(pi/2 + 2* xdata * x(2));

end

