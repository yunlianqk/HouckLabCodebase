function specparams = GetSpecParams(pnax)
% Get spectroscopy parameters
    specparams = paramlib.pnax.spec();
    
    specparams.channel = pnax.GetActiveChannel();
    
    specparams.trace = pnax.GetActiveTrace();
    
    fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STARt?', ...
            specparams.channel);
    specparams.start = fscanf(pnax.instrhandle, '%g');

    fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STOP?', ...
            specparams.channel);
    specparams.stop = fscanf(pnax.instrhandle, '%g');

    fprintf(pnax.instrhandle, 'SOURce%d:POWer3?', ...
            specparams.channel);
    specparams.power = fscanf(pnax.instrhandle, '%g');

    fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:CW?', ...
            specparams.channel);
    specparams.cwfreq = fscanf(pnax.instrhandle, '%g');                

    fprintf(pnax.instrhandle, 'SOURce%d:POWer1?', ...
            specparams.channel);
    specparams.cwpower = fscanf(pnax.instrhandle, '%g');
    
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts?', specparams.channel);
    specparams.points = fscanf(pnax.instrhandle, '%g');

    fprintf(pnax.instrhandle, 'SOURce%d:POWer1?', specparams.channel);
    specparams.power = fscanf(pnax.instrhandle, '%g');

    fprintf(pnax.instrhandle, 'SENSe%d:BANDwidth?', specparams.channel);
    specparams.ifbandwidth = fscanf(pnax.instrhandle, '%g');

    fprintf(pnax.instrhandle, 'SENSe%d:AVERage:COUNt?', specparams.channel);
    specparams.averages = fscanf(pnax.instrhandle, '%d');

    fprintf(pnax.instrhandle, 'CALCulate%d:FORMat?', specparams.channel);
    specparams.format = fscanf(pnax.instrhandle, '%s');

    specparams.meastype = pnax.GetMeasType(pnax.GetActiveMeas());
end