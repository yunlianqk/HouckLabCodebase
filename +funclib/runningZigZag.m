xdata=x.numGateVector-1;
ydata=sqrt(result.Pint);
ymin=ydata(end-1);
ymax=ydata(end);
amp=ymax-ymin;
ydata_clean = (ydata(1:end-2)-ymin)/amp;
figure();plot(xdata,ydata_clean)
plotlib.hline(0)
plotlib.hline(1)
%%
ratio = funclib.amp90correction(xdata, ydata_clean)
% ratio = funclib.amp180correction(xdata, ydata_clean)

%% 
xnew=xdata/2;
ratio = funclib.amp180correction(xnew, ydata_clean)

%% seems a positive error corresponds to an under rotation.... 
err = -pi/100;
n=[0:.1:10];
n2=[0:10];
y=.5+.5*(-1).^n.*cos(pi/2-n.*err);
y2=.5+.5*(-1).^n2.*cos(pi/2-n2.*err);

figure();
plot(n,y,n2,y2)
plotlib.hline(0);plotlib.hline(1)


%%
figure()
rr = funclib.AmplitudeZigZagFit(result.xaxisNorm, result.AmpNorm)