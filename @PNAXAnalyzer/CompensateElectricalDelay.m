function CompensateElectricalDelay(pnax)
% switches to group delay, estimates it, and then compensates for it
    currentFormat = pnax.params.format;
    pnax.params.format = 'GDEL';
    delayLine = pnax.ReadTrace();
    delay = median(delayLine);
    figure(512);plot(delayLine);hold on; plot(ones(size(delayLine)).*delay,'r');hold off
    channel = pnax.GetActiveChannel;
    fprintf(pnax.instrhandle, ['CALC' num2str(channel) ':CORR:EDEL ' num2str(delay)]);
    pnax.params.format = currentFormat;
end