function SetS41SpecParams(pnax)
% Perform spectroscopy measurement
    instr = pnax.instrhandle;
    S41specparams = pnax.S41specparams;
    % Create measurement and trace
    pnax.CheckParams(S41specparams);
    pnax.CreateMeas(pnax.S41specchannel, S41specparams.trace, S41specparams.meastype, ...
                    S41specparams.format); 
    
    % Set parameters
    fprintf(instr, 'SENSe2:FOM:RANGe4:COUPled OFF');
    fprintf(instr, 'SENSe2:FOM:RANGe4:SWEep:TYPE LINear');
    fprintf(instr, 'SENse2:FOM ON');
    fprintf(instr, 'SENse2:FOM:DISPlay:SELect ''source2''');
    fprintf(instr, ['SENse2:FOM:RANGe4:FREQuency:STARt ' num2str(S41specparams.start)]);
    fprintf(instr, ['SENse2:FOM:RANGe4:FREQuency:STOP ' num2str(S41specparams.stop)]);
    fprintf(instr, ['SENSe2:SWEep:POINts ' num2str(S41specparams.points)]);
    fprintf(instr, 'SOURce2:POWer:COUPle OFF');
    fprintf(instr, ['SOURce2:POWer3 ' num2str(S41specparams.power)]);
    fprintf(instr, ['SENSe2:AVERage:COUNt ' num2str(S41specparams.averages)]);
    fprintf(instr, ['SENSe2:BANDwidth ' num2str(S41specparams.ifbandwidth)]);
    fprintf(instr, ['SENSe2:FREQuency:CW ' num2str(S41specparams.cwfreq)]);
    fprintf(instr, ['SOURce2:POWer1 ' num2str(S41specparams.cwpower)]);
    fprintf(instr, 'SOURce2:POWer3:MODE ON');

    
    fprintf(instr, 'SENSe2:AVERage ON');
    fprintf(instr, 'OUTPut ON');
    fprintf(instr, 'SENSe2:SWEep:MODE CONTinuous');
end