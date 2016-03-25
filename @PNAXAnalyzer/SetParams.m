function SetParams(pnax, params)
% Set up a measurement with given parameters

    % Check parameters
    if ~pnax.CheckParams(params)
        display('Parameters are not set correctly.');
        return;
    end
    % Create measurement  
    pnax.CreateMeas(params.channel, params.trace, params.meastype); 

    % If channel has the same measurement class, update the parameters
    tempparams = pnax.GetParams();
    if strcmp(tempparams.measclass, params.measclass)
        switch params.measclass
            case 'trans'
                pnax.UpdateTransParams(tempparams, params);
            case 'spec'
                pnax.UpdateSpecParams(tempparams, params);
            otherwise
                display('Unexpected measurement class');
        end
        return;
    end
    
    % Otherwise, set up the parameters
    switch params.measclass
        case 'trans'
            pnax.SetTransParams(params);
        case 'spec'
            pnax.SetSpecParams(params);
        otherwise
            display('Unexpected measurement class');
    end  
end