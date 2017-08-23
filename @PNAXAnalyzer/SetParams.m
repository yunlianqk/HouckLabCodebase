function SetParams(pnax, params)
% Set up a measurement with given parameters

    % Check parameters
    if ~pnax.CheckParams(params)
        disp('Parameters are not set correctly.');
        return;
    end
    % Create measurement  
    pnax.CreateMeas(params.channel, params.trace, params.meastype); 

    % Get old parameters
    oldparams = pnax.GetParams();
    % Find the measurement class for new parameters
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
                disp(['Unknow measurement class ', measclass]);
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
            disp(['Unknow measurement class ', measclass]);
    end
end