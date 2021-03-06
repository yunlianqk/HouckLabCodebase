function SetSpecParams(pnax, specparams)
% Set spectroscopy parameters
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:TYPE CW', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SENSe%d:FOM:RANGe4:COUPled OFF', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SENSe%d:FOM:RANGe4:SWEep:TYPE LINear', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SENse%d:FOM ON', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SENse%d:FOM:DISPlay:SELect ''source2''', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STARt %f', ...
            [specparams.channel, specparams.start]);
    fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STOP %f', ...
            [specparams.channel, specparams.stop]);
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts %d', ...
            [specparams.channel, specparams.points]);
    fprintf(pnax.instrhandle, 'SOURce%d:POWer:COUPle OFF', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SOURce%d:POWer3 %f', ...
            [specparams.channel, specparams.specpower]);
    fprintf(pnax.instrhandle, 'SENSe%d:AVERage:COUNt %d', ...
            [specparams.channel, specparams.averages]);
    fprintf(pnax.instrhandle, 'SENSe%d:AVERage:MODE %s', ...
            [specparams.channel, specparams.avgmode]);
    fprintf(pnax.instrhandle, 'SENSe%d:BANDwidth %f', ...
            [specparams.channel, specparams.ifbandwidth]);
    fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:CW %f', ...
            [specparams.channel, specparams.cwfreq]);
    fprintf(pnax.instrhandle, sprintf('SOURce%d:POWer%s %f',  ...
                                      specparams.channel, ...
                                      specparams.meastype(end), ...
                                      specparams.cwpower));
    fprintf(pnax.instrhandle, 'SOURce%d:POWer3:MODE ON', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'CALCulate%d:FORMat %s', ...
            [specparams.channel, specparams.format]);
end