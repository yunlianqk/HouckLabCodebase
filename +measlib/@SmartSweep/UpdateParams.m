function UpdateParams(self, config)
% Update properties from config
    % If config is a 'paramlib.pulseCal' object
    if isa(config, 'paramlib.pulseCal')
        self.rffreq = config.cavityFreq;
        self.rfpower = config.rfPower;
        self.specfreq = config.qubitFreq;
        self.specpower = config.specPower;
        self.intfreq = config.intFreq;
        self.lopower = config.loPower;
        self.startBuffer = config.startBuffer;
        self.measBuffer = config.measBuffer;
        self.endBuffer = config.endBuffer;
        return;
    end
    % If config is a struct
    if isstruct(config)
        for p = fieldnames(config)'
            if isprop(self, p{:})
                self.(p{:}) = config.(p{:});
            end
        end
    end
    % If config is an object
    if isobject(config)
        for p = properties(config)'
            if isprop(self, p{:})
                self.(p{:}) = config.(p{:});
            end
        end
    end
end