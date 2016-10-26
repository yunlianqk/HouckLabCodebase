x0 = [0.5,0.010];
x = lsqcurvefit(@amp_error_paper, x0, ax2_xaxis/2,ax2_data)
code_error = amp_error_paper(x, ax2_xaxis/2);
plot(ax2_xaxis, code_error,ax2_xaxis, ax2_data )
legend('corrected','measured')