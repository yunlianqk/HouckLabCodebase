classdef Instr
    % Instruments for pulsed measurements
    
    properties
        qpulsegen = []; % AWG for qubit drive pulse
        mpulsegen = []; % AWG for measurement pulse
        rfgen = []; % microwave generator for measurement carrier
        specgen = []; % microwave generator for drive carrier
        logen = []; % microwave generator for local oscillator
        triggen = []; % Low frequency AWG that generates trigger
        digitizer = []; % digitizer for data acquisition
    end 
end