classdef RepeatGates < measlib.SmartSweep
    % Running gates in repeated pattern
    
    % Typically for error amplification in gate calibration
    % The pattern is defined as initGates*(repeatGates)^n*endGates
    % where n is specified by repeatVector
    % (init/repeat/end)Gates are all cellstr's that contain the names of gates
    % Example:
    % initGates = {'X90'}, repeatGates = {'X180', 'Y180'}, endGates = {'Y90'}
    % repeatVector = 0:2:4
    % generates the following sequence:
    % X90*Y90, X90*(X180*Y180)^2*Y90, X90*(X180*Y180)^4*Y90
    
    % All primary gates are stored in self.gatedict and can be accessed by
    % self.gatedict.(name), e.g. self.gatedic.('X180') returns the X180 gate
    
    properties 
        initGates;
        repeatGates;
        endGates;
        repeatVector;
        % Pre-calculated waveforms to speed up pulse generation
        gatedict = struct();
        iGateWaveforms = struct();
        qGateWaveforms = struct();
    end
    
    methods
        function self = RepeatGates(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
            self.normalization = 1;
            self.speccw = 0;
            self.rfcw = 0;
        end
        
        function SetUp(self)
            % Update params from pulseCal
            self.specfreq = self.pulseCal.qubitFreq;
            self.specpower = self.pulseCal.specPower;
            self.rffreq = self.pulseCal.cavityFreq;
            self.rfpower = self.pulseCal.rfPower;
            self.intfreq = self.pulseCal.intFreq;
            self.lopower = self.pulseCal.loPower;
            self.startBuffer = self.pulseCal.startBuffer;
            self.measBuffer = self.pulseCal.measBuffer;
            self.endBuffer = self.pulseCal.endBuffer;
            self.cardavg = self.pulseCal.cardAvg;
            self.carddelayoffset = self.pulseCal.cardDelayOffset;
            
            % Construct and store primary gates
            self.gatedict = struct();
            self.gatedict.Identity = self.pulseCal.Identity();
            self.gatedict.X180 = self.pulseCal.X180();
            self.gatedict.Xm180 = self.pulseCal.Xm180();
            self.gatedict.X90 = self.pulseCal.X90();
            self.gatedict.Xm90 = self.pulseCal.Xm90();
            self.gatedict.Y180 = self.pulseCal.Y180();
            self.gatedict.Ym180 = self.pulseCal.Ym180();
            self.gatedict.Y90 = self.pulseCal.Y90();
            self.gatedict.Ym90 = self.pulseCal.Ym90();
            
            % Construct gate sequences
            if ~isempty(self.initGates) && ~iscell(self.initGates)
                    self.initGates = cellstr(self.initGates);
            end
            if ~isempty(self.repeatGates) && ~iscell(self.repeatGates)
                    self.repeatGates = cellstr(self.repeatGates);
            end
            if ~isempty(self.endGates) && ~iscell(self.endGates)
                    self.endGates = cellstr(self.endGates);
            end
            
            self.gateseq = pulselib.gateSequence();
            for row = 1:length(self.repeatVector)
                self.gateseq(row) = pulselib.gateSequence();
                for col = 1:length(self.initGates)
                    self.gateseq(row).append(self.gatedict.(self.initGates{col}));
                end
                for repeat = 1:self.repeatVector(row)
                    for col = 1:length(self.repeatGates)
                        self.gateseq(row).append(self.gatedict.(self.repeatGates{col}));
                    end
                end
                for col = 1:length(self.endGates)
                    self.gateseq(row).append(self.gatedict.(self.endGates{col}));
                end
            end
            
            % Construct measurement pulse
            self.measpulse = self.pulseCal.measurement();
            
            self.result.rowAxis = self.repeatVector;
            SetUp@measlib.SmartSweep(self);
        end
    end
end