function SetS41TransParams(pnax)
% Perform S41 transmission measurement
    instr = pnax.instrhandle;
    S41transparams = pnax.S41transparams;
    % Create measurement and trace
    pnax.CheckParams(S41transparams);
    pnax.CreateMeas(pnax.S41transchannel, S41transparams.trace, S41transparams.meastype, ...
                    S41transparams.format); 
    
    % Set parameters
    fprintf(instr, ['SENSe3:FREQuency:STARt ' num2str(S41transparams.start)]);
    fprintf(instr, ['SENSe3:FREQuency:STOP ' num2str(S41transparams.stop)]);
    fprintf(instr, ['SENSe3:SWEep:POINts ' num2str(S41transparams.points)]);
    fprintf(instr, ['SOURce3:POWer1 ' num2str(S41transparams.power)]);
    fprintf(instr, ['SENSe3:BANDwidth ' num2str(S41transparams.ifbandwidth)]);
    fprintf(instr, 'SENSe3:AVERage ON');
    fprintf(instr, ['SENSe3:AVERage:COUNt ' num2str(S41transparams.averages)]);
    
    fprintf(instr, 'OUTPut ON');    
    fprintf(instr, 'SENSe3:SWEep:MODE CONTinuous');
end