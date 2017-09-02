function specparams = GetSpecParams(pnax)
% Get spectroscopy parameters
    specparams = paramlib.pnax.spec();

    specparams.channel = pnax.GetActiveChannel();

    specparams.trace = pnax.GetActiveTrace();

    specparams.meastype = pnax.GetMeasType(pnax.GetActiveMeas());

    fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STARt?', ...
            specparams.channel);
    specparams.start = fscanf(pnax.instrhandle, '%f');

    fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STOP?', ...
            specparams.channel);
    specparams.stop = fscanf(pnax.instrhandle, '%f');

    fprintf(pnax.instrhandle, 'SOURce%d:POWer3?', ...
            specparams.channel);
    specparams.specpower = fscanf(pnax.instrhandle, '%f');

    fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:CW?', ...
            specparams.channel);
    specparams.cwfreq = fscanf(pnax.instrhandle, '%f');                

    fprintf(pnax.instrhandle, 'SOURce%d:POWer%s?', ...
            [specparams.channel, specparams.meastype(end)]);
    specparams.cwpower = fscanf(pnax.instrhandle, '%f');

    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts?', specparams.channel);
    specparams.points = fscanf(pnax.instrhandle, '%d');

    fprintf(pnax.instrhandle, 'SENSe%d:BANDwidth?', specparams.channel);
    specparams.ifbandwidth = fscanf(pnax.instrhandle, '%f');

    fprintf(pnax.instrhandle, 'SENSe%d:AVERage:COUNt?', specparams.channel);
    specparams.averages = fscanf(pnax.instrhandle, '%d');

    fprintf(pnax.instrhandle, 'SENSe%d:AVERage:MODE?', specparams.channel);
    switch upper(fscanf(pnax.instrhandle, '%s'))
        case 'SWE'
            specparams.avgmode = 'SWEEP';
        case 'POIN'
            specparams.avgmode = 'POINT';
        otherwise
    end

    fprintf(pnax.instrhandle, 'CALCulate%d:FORMat?', specparams.channel);
    specparams.format = fscanf(pnax.instrhandle, '%s');
end