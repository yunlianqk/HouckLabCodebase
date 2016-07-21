classdef m9703a
    % defines the properties for M9703A Digitier
    
    properties
        samplerate=1.6e9;   % Hz units
        samples=1.6e9*3e-6;    % samples for a single trace
        averages=8000;  % software averages=number of traces acquired
        segments=1; % segments>1 => sequence mode in readIandQ
        fullscale=1; % in units of V, IT CAN ONLY TAKE VALUE:1,2, other values will give an error
        offset=0;    % in units of volts
        coupledmode=1; % 1= 50hm DC
        enabled=true;
        delaytime=5e-6; % Delay time from trigger to start of acquistion, units second
        
        ChI='Channel1';
        ChQ='Channel2';
        
        TrigSource='External1'; %TRG1 input
        TrigType='AgMD1TriggerEdge';
        TrigLevel=0.5; %Trigger level in units of Volts
        TrigPeriod=100e-3; % ms units
    end
    
    methods
        function s = toStruct(self)
            s = paramlib.obj2struct(self);
        end
    end
end