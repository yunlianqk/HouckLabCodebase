function CompensateElectricalDelay(pnax,channel,trace)
% for given trace it switches to group delay, estimates it, and then compensates for it
    measname = pnax.MeasName(channel,trace);
    fprintf(pnax.instrhandle, ['CALCulate' num2str(channel) ':PARameter:SELect ''' measname '''']);
    fprintf(pnax.instrhandle, ['CALCulate' num2str(channel) ':FORMat GDELay']);
    
    % read and average to find delay
    delayLine = read_PNAX_fancy(instr,channel,traceName);
    delay = median(delayLine);
    figure(512);plot(delayLine);hold on; plot(ones(size(delayLine)).*delay,'r');hold off
    
    % set electrical delay and switch back to phase format
    fprintf(pnax.instrhandle, ['CALCulate' num2str(channel) ':CORRection:EDELay ' num2str(delay)]);
    fprintf(pnax.instrhandle, ['CALCulate' num2str(channel) ':PARameter:SELect ''' traceName '''']);
    fprintf(pnax.instrhandle, ['CALCulate' num2str(channel) ':FORMat UPHase']);
    fprintf(pnax.instrhandle, 'DISPlay:WINDow:Y:AUTO')
end