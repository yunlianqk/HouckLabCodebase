function [ output_args ] = Gate_Cal_fun( gate, )
    %% Create objects
    params = measlib.QPulseMeas.Params();
    instr = measlib.QPulseMeas.Instr();
    GateMeas = measlib.GateCalib();
    %% Set up parameters
    params.driveFreq = 9.275e9 + 3e6;
    params.drivePower = -6;
    params.measFreq = 7.664e9;
    params.measPower = -20;
    params.intFreq = 0;
    params.loPower = 11;
    params.measDuration = 1e-6;
    params.numAvg = 65536;
    params.trigPeriod = 40e-6;
    params.cardDelay = 0e-6;

    GateMeas.params = params;
    %% Set up instruments
    % If you name the instrument differently, change the object names accordingly
    instr.qpulsegen = pulsegen1;
    instr.mpulsegen = pulsegen2;
    instr.rfgen = rfgen;
    instr.specgen = specgen;
    instr.logen = logen;
    instr.digitizer = card;
    instr.triggen = triggen;

    GateMeas.instr = instr;

end

