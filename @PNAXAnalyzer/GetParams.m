function params = GetParams(pnax)
% Return a struct that contains the parameters of the active trace
    
    if isempty(pnax.GetActiveChannel())
        params = [];
    else
        channel = pnax.GetActiveChannel();
        meas = pnax.GetActiveMeas();
        % Select the active measurement
        fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:SELect ''%s''', ...
                [channel, meas]);
            
        isspec = pnax.IsSpec(channel);
        if isspec
        % If active channel is spec scan, get specparams
            params = pnax.GetSpecParams();
            return;
        end
        % Else, get transparams
        params = pnax.GetTransParams();
    end
end