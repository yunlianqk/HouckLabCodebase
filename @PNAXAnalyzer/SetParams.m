function SetParams(pnax, params)
% Set up a measurement with given parameters

    % Check parameters
    if ~pnax.CheckParams(params)
        display('Parameters are not set correctly.');
        return;
    end
    % Create measurement  
    pnax.CreateMeas(params.channel, params.trace, params.meastype); 

    oldparams = pnax.GetParams();
    measclass = strsplit(class(params), '.');
    measclass = measclass{end};
    
    % If channel has the same measurement class, update the parameters    
    if strcmp(class(oldparams), class(params))
        switch measclass
            case 'trans'
                pnax.UpdateTransParams(oldparams, params);
            case 'spec'
                pnax.UpdateSpecParams(oldparams, params);
            case 'psweep'
                pnax.UpdatePsweepParams(oldparams, params);
            otherwise
                display('Unexpected measurement class');
        end
        return;
    end
    
    % Otherwise, clear the channel and set up the parameters
    pnax.DeleteChannel(params.channel);
    pnax.CreateMeas(params.channel, params.trace, params.meastype);
    switch measclass
        case 'trans'
            pnax.SetTransParams(params);
        case 'spec'
            pnax.SetSpecParams(params);
        case 'psweep'
            pnax.SetPsweepParams(params);
        otherwise
            display('Unexpected measurement class');
    end
end