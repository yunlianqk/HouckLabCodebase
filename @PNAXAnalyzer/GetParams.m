function params = GetParams(pnax)
% Return an object that contains the parameters of the active trace
    
    if isempty(pnax.GetActiveChannel())
        params = [];
        return;
    end
    
    % Select the active measurement
    channel = pnax.GetActiveChannel();
    meas = pnax.GetActiveMeas();
    fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:SELect ''%s''', ...
            [channel, meas]);

    % Check the measurement class
    measclass = 'trans';
    if pnax.IsSpec(channel)
        measclass = 'spec';
    end
    if pnax.IsPsweep(channel)
        measclass = 'psweep';
    end
    
    % Get the parameters
    switch measclass
        case 'trans'
            params = pnax.GetTransParams();
        case 'spec'
            params = pnax.GetSpecParams();
        case 'psweep'
            params = pnax.GetPsweepParams();
        otherwise
            display('Unexpected measurement class');
    end

end