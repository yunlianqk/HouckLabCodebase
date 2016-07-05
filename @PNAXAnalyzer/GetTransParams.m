function transparams = GetTransParams(pnax)
% Get transmission parameters
    transparams = paramlib.pnax.trans();
    
    transparams.channel = pnax.GetActiveChannel();
    
    transparams.trace = pnax.GetActiveTrace();
    
    fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:STARt?', transparams.channel);
    transparams.start = fscanf(pnax.instrhandle, '%f');

    fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:STOP?', transparams.channel);
    transparams.stop = fscanf(pnax.instrhandle, '%f');
    
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts?', transparams.channel);
    transparams.points = fscanf(pnax.instrhandle, '%d');

    fprintf(pnax.instrhandle, 'SOURce%d:POWer1?', transparams.channel);
    transparams.power = fscanf(pnax.instrhandle, '%f');

    fprintf(pnax.instrhandle, 'SENSe%d:BANDwidth?', transparams.channel);
    transparams.ifbandwidth = fscanf(pnax.instrhandle, '%f');

    fprintf(pnax.instrhandle, 'SENSe%d:AVERage:COUNt?', transparams.channel);
    transparams.averages = fscanf(pnax.instrhandle, '%d');

    fprintf(pnax.instrhandle, 'CALCulate%d:FORMat?', transparams.channel);
    transparams.format = fscanf(pnax.instrhandle, '%s');

    transparams.meastype = pnax.GetMeasType(pnax.GetActiveMeas());
end