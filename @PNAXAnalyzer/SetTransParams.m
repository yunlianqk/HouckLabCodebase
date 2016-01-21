function SetTransParams(pnax)
% Perform transmission measurement
    instr = pnax.instrhandle;
    transparams = pnax.transparams;
    
    % Select the first measurement in channel 1
    fprintf(instr, 'CALCulate1:PARameter:CATalog:EXTended?');
    tempstr = fscanf(instr, '%s');
    tempstr = strsplit(tempstr(2:end-1), ',');
    fprintf(instr, ['CALCulate1:PARameter:SELect ', tempstr{1}]);
    
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