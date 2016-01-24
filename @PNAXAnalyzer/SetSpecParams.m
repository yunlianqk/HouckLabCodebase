function SetSpecParams(pnax)
% Perform spectroscopy measurement
    instr = pnax.instrhandle;
    specparams = pnax.specparams;
    
    pnax.GetChannels();
    % If channel 2 does not exist
    if (~ismember(2, pnax.channels))
        fprintf(instr, ['CALCulate2:PARameter:EXTended ', pnax.spectrace1, ', S21']);
        fprintf(instr, ['DISPlay:WINDow:TRACe3:feed ', pnax.spectrace1]);
        fprintf(instr, ['CALCulate2:PARameter:SELect ', pnax.spectrace1]);
        fprintf(instr, 'CALCulate2:FORMat MLOG');
        fprintf(instr, 'SENSe2:SWEep:TYPE CW');
    end    
    % Select the first measurement in channel 2
    fprintf(instr, 'CALCulate2:PARameter:CATalog:EXTended?');
    tempstr = fscanf(instr, '%s');
    tempstr = strsplit(tempstr(2:end-1), ',');
    fprintf(instr, ['CALCulate2:PARameter:SELect ', tempstr{1}]);
    
    % Set parameters
    fprintf(instr, ['SENse2:FOM:RANGe4:FREQuency:STARt ' num2str(specparams.start)]);
    fprintf(instr, ['SENse2:FOM:RANGe4:FREQuency:STOP ' num2str(specparams.stop)]);
    fprintf(instr, 'SOURce2:POWer:COUPle OFF');
    fprintf(instr, ['SOURce2:POWer3 ' num2str(specparams.power)]);
    fprintf(instr, ['SENSe2:SWEep:POINts ' num2str(specparams.points)]);
    fprintf(instr, 'SENSe2:AVERage ON');
    fprintf(instr, ['SENSe2:AVERage:COUNt ' num2str(specparams.averages)]);
    fprintf(instr, ['SENSe2:BANDwidth ' num2str(specparams.ifbandwidth)]);
    fprintf(instr, ['SENSe2:FREQuency:CW ' num2str(specparams.cwfreq)]);
    fprintf(instr, 'SENSe2:FOM:RANGe4:COUPled OFF');
    fprintf(instr, 'SENSe2:FOM:RANGe4:SWEep:TYPE LINear');
    fprintf(instr, ['SOURce2:POWer1 ' num2str(specparams.cwpower)]);
    fprintf(instr, 'SOURce2:POWer3:MODE ON');
    fprintf(instr, 'SENse2:FOM:DISPlay:SELect ''source2''');
    fprintf(instr, 'SENse2:FOM ON');
    
    fprintf(instr, 'OUTPut ON');
    fprintf(instr, 'SENSe2:SWEep:MODE CONTinuous');
end