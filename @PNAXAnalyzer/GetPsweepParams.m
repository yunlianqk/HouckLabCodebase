function psweepparams = GetPsweepParams(pnax)
% Get spectroscopy parameters
    psweepparams = PSWEEPParams();
    
    psweepparams.channel = pnax.GetActiveChannel();
    
    psweepparams.trace = pnax.GetActiveTrace();
    
    fprintf(pnax.instrhandle, 'SOURce%d:POWer1:STARt?', psweepparams.channel);
    psweepparams.start = fscanf(pnax.instrhandle, '%g');

    fprintf(pnax.instrhandle, 'SOURce%d:POWer1:STOP?', psweepparams.channel);
    psweepparams.stop = fscanf(pnax.instrhandle, '%g');

    fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:CW?', psweepparams.channel);
    psweepparams.cwfreq = fscanf(pnax.instrhandle, '%g');                

    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts?', psweepparams.channel);
    psweepparams.points = fscanf(pnax.instrhandle, '%g');

    fprintf(pnax.instrhandle, 'SENSe%d:BANDwidth?', psweepparams.channel);
    psweepparams.ifbandwidth = fscanf(pnax.instrhandle, '%g');

    fprintf(pnax.instrhandle, 'SENSe%d:AVERage:COUNt?', psweepparams.channel);
    psweepparams.averages = fscanf(pnax.instrhandle, '%d');

    fprintf(pnax.instrhandle, 'CALCulate%d:FORMat?', psweepparams.channel);
    psweepparams.format = fscanf(pnax.instrhandle, '%s');

    psweepparams.meastype = pnax.GetMeasType(pnax.GetActiveMeas());
end