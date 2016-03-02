function SetTransParams(pnax)
% Perform transmission measurement
    instr = pnax.instrhandle;
    transparams = pnax.transparams;
    % Create measurement and trace
    pnax.CheckParams(transparams);
    pnax.CreateMeas(pnax.transchannel, transparams.trace, transparams.meastype, ...
                    transparams.format); 
    
    % Set parameters
    fprintf(instr, ['SENSe1:FREQuency:STARt ' num2str(transparams.start)]);
    fprintf(instr, ['SENSe1:FREQuency:STOP ' num2str(transparams.stop)]);
    fprintf(instr, ['SENSe1:SWEep:POINts ' num2str(transparams.points)]);
    fprintf(instr, ['SOURce1:POWer1 ' num2str(transparams.power)]);
    fprintf(instr, ['SENSe1:BANDwidth ' num2str(transparams.ifbandwidth)]);
    fprintf(instr, 'SENSe1:AVERage ON');
    fprintf(instr, ['SENSe1:AVERage:COUNt ' num2str(transparams.averages)]);
    
    fprintf(instr, 'OUTPut ON');    
    fprintf(instr, 'SENSe1:SWEep:MODE CONTinuous');
end