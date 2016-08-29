function y = ExpCos_beta(beta, x)
    amp = beta(1);
    lambda = beta(2);
    offset = beta(3);
    fringefreq = beta(4);
    phaseoffset = beta(5);
    y = offset+(amp*exp(-x/lambda).*cos(2*pi*fringefreq*x+phaseoffset));
end