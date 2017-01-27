classdef m9703a
    % defines the properties for M9703A Digitier
    
    properties
        samplerate=1.6e9;   % Hz units
        samples=1.6e9*8.0e-6;    % samples for a single trace
        averages=1;  % software averages PER SEGMENT; total avg=self.averages*self.segments
        segments=1; % segments>1 => sequence mode in readIandQ
        fullscale=1; % in units of V, IT CAN ONLY TAKE VALUE:1,2, other values will give an error
        offset=0;    % in units of volts
        couplemode='DC'; % 'DC'/'AC'
        delaytime=0.5e-6; % Delay time from trigger to start of acquistion, units second
        ChI='Channel2';
        ChQ='Channel3';
        ChI2='Channel4';
        ChQ2='Channel5';
        trigSource='Channel1'; % Trigger source
        trigLevel=0.5; % Trigger level in volts
        trigPeriod=6e-6; % Trigger period in seconds
    end
    
    methods
        function s = toStruct(self)
            s = funclib.obj2struct(self);
        end
    end
end