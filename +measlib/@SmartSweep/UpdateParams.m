function UpdateParams(self, config)
% Update properties from config

    global rfgen specgen logen rfgen2 specgen2 logen2 fluxgen pulsegen1 pulsegen2;
    
    % Set default generators
    if isempty(self.generator)
        self.generator = {specgen, [], fluxgen, rfgen, logen, [], []};
    end
    
    % Set default awg routing
    if isempty(self.awg)
        self.awg = {pulsegen1, [], pulsegen2, pulsegen2, []};
    end
    if isempty(self.awgchannel)
        self.awgchannel = {{'waveform1', 'waveform2'}, [], {'waveform2'}, {'waveform1'}, []};
    end

    % If config is a 'paramlib.pulseCal' object
    if isa(config, 'paramlib.pulseCal')
        if ~isempty(self.generator{1})
        % Update generator parameters for gateseq
            switch self.generator{1}
                case specgen
                    self.specfreq = config.qubitFreq;
                    self.specpower = config.specPower;
                case specgen2
                    self.spec2freq = config.qubitFreq;
                    self.spec2power = config.specPower;
                otherwise
            end
        end
        if ~isempty(self.generator{3})
        % Update generator parameters for fluxseq
            self.fluxfreq = config.fluxFreq;
            self.fluxpower = config.fluxPower;
        end 
        if ~isempty(self.generator{4})
        % Update generator parameters for measseq
            switch self.generator{4}
                case rfgen
                    self.rffreq = config.cavityFreq;
                    self.rfpower = config.rfPower;
                case rfgen2
                    self.rf2freq = config.cavityFreq;
                    self.rf2power = config.rfPower;
                otherwise
            end
        end
        if ~isempty(self.generator{5})
        % Update LO parameters for measseq
            switch self.generator{5}
                case logen
                    self.intfreq = config.intFreq;
                    self.lopower = config.loPower;
                case logen2
                    self.int2freq = config.intFreq;
                    self.lo2power = config.loPower;
                otherwise
            end
        end
        % Update pulse timing parameters
        self.startBuffer = config.startBuffer;
        self.measBuffer = config.measBuffer;
        self.endBuffer = config.endBuffer;

        if ~isempty(self.pulseCal2)
        % Update from pulseCal2 if it exists
            if ~isempty(self.generator{2})
            % Update generator parameters for gateseq2
                switch self.generator{2}
                    case specgen
                        self.specfreq = self.pulseCal2.qubitFreq;
                        self.specpower = self.pulseCal2.specPower;
                    case specgen2
                        self.spec2freq = self.pulseCal2.qubitFreq;
                        self.spec2power = self.pulseCal2.specPower;
                    otherwise
                end
            end
            if ~isempty(self.generator{6})
            % Update generator parameters for measseq2
                switch self.generator{6}
                    case rfgen
                        self.rffreq = self.pulseCal2.cavityFreq;
                        self.rfpower = self.pulseCal2.rfPower;
                    case rfgen2
                        self.rf2freq = self.pulseCal2.cavityFreq;
                        self.rf2power = self.pulseCal2.rfPower;
                    otherwise
                end
            end
            if ~isempty(self.generator{7})
            % Update LO parameters for measseq2
                switch self.generator{7}
                    case logen
                        self.intfreq = self.pulseCal2.intFreq;
                        self.lopower = self.pulseCal2.loPower;
                    case logen2
                        self.int2freq = self.pulseCal2.intFreq;
                        self.lo2power = self.pulseCal2.loPower;
                    otherwise
                end
            end
        end
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