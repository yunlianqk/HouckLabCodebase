function SetDefault(pnax)
% Configure PNAX to default settings
    instr = pnax.instrhandle;
    % Delete all used channels
    fprintf(instr, 'SYSTem:CHANnels:HOLD');
    fprintf(instr, 'SYSTem:CHANnels:CATalog?');
    tempstr = fscanf(instr, '%s');
    chlist = sscanf(tempstr(2:end-1), '%d,');
    for channel = chlist'
        fprintf(instr, ['SYSTem:CHANnels:DELete ', num2str(channel)]);
    end
    fprintf(instr, 'OUTPut OFF');

    % Measure S21
    fprintf(instr, ['CALCulate1:PARameter:EXTended ', ...
                               pnax.transtrace1, ', S21']);
    % Channel 1, trace 1, transmission amplitude
    fprintf(instr, ['DISPlay:WINDow:TRACe1:feed ', pnax.transtrace1]);
    fprintf(instr, ['CALCulate1:PARameter:SELect ', pnax.transtrace1]);
    fprintf(instr, 'CALCulate1:FORMat MLOG');
    % Channel 1, trace 2, transmission phase
    fprintf(instr, ['CALCulate1:PARameter:EXTended ', ...
                               pnax.transtrace2, ', S21']);
    fprintf(instr, ['DISPlay:WINDow:TRACe2:feed ', pnax.transtrace2]);
    fprintf(instr, ['CALCulate1:PARameter:SELect ', pnax.transtrace2]);
    fprintf(instr, 'CALCulate1:FORMat UPHase');
    % Turn on average
    fprintf(instr, 'SENSe1:AVERage ON');


    fprintf(instr, ['CALCulate2:PARameter:EXTended ', ...
                               pnax.spectrace1, ', S21']);
    % Channel 2, trace 3, spectroscopy amplitude
    fprintf(instr, ['DISPlay:WINDow:TRACe3:feed ', pnax.spectrace1]);
    fprintf(instr, ['CALCulate2:PARameter:SELect ', pnax.spectrace1]);
    fprintf(instr, 'CALCulate2:FORMat MLOG');
    fprintf(instr, 'SENSe2:SWEep:TYPE CW');
    % Channel 2, trace 4, spectroscopy phase
    fprintf(instr, ['CALCulate2:PARameter:EXTended ', ...
                               pnax.spectrace2, ', S21']);
    fprintf(instr, ['DISPlay:WINDow:TRACe4:feed ', pnax.spectrace2]);
    fprintf(instr, ['CALCulate2:PARameter:SELect ', pnax.spectrace2]);
    fprintf(instr, 'CALCulate2:FORMat UPHase');

    % set primary source into CW mode
    fprintf(instr, 'SENSe2:SWEep:TYPE CW');
    % Set source 2 into linear frequency sweep mode 
    fprintf(instr, 'SENSe2:FOM:RANGe4:COUPled OFF');
    fprintf(instr, 'SENSe2:FOM:RANGe4:SWEep:TYPE LINear');
    % Set spec tone as port 3 
    fprintf(instr, 'SOURce2:POWer:COUPle OFF');
    fprintf(instr, 'SOURce2:POWer3:MODE ON');
    % Set x axis as spec frequency
    fprintf(instr, 'SENse2:FOM:DISPlay:SELect ''source2''');
    fprintf(instr, 'SENse2:FOM ON');
    % Turn on avearage
    fprintf(instr, 'SENSe2:AVERage ON');            
end