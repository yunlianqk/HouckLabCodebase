function ispsweep = IsPsweep(pnax, channel)
% Check if a channel is power sweep measurement
    ispsweep = 0;
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:TYPE?', channel);
    reply = fscanf(pnax.instrhandle, '%s');
    if strcmp(reply, 'POW') 
        ispsweep = 1;
    end
end