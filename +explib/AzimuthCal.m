classdef AzimuthCal < explib.SweepM8195
	% DRAG like calibration for the azimuth of single qubit gates
    % 'qubitGates' is a cellstr that contains the name of the gate to be calibated
	% It can be {'Y180'}, {'Y90'}, or {'X90'}
	% 'numRepeats' specfifies how many pulse sequences are concatenated
	% to amplify azimuth error (see explanation below)
	% 'azimuthVector' is the azimuth angles that are swept
	
	% For Y180, Y90, X90 gates, the pulse sequences are
	% X90*(Ym180*X180*Y180*X180)^n*Y90,
	% X90*(Ym90*Ym90*X180*Y90*Y90*X180)^n*Y90,
	% Y90*(Xm90*Xm90*Y180*X90*X90*Y180)^n*X90,
	% respectively and n = 'numRepeats'.
	
	% The result should be a cosine like curve with P(|0>) = 0.5 for optimal azimuth
	
    properties
        qubitGates = {'Y90'};
        numRepeats = 3;
        azimuthVector = linspace((85/180*pi),(95/180*pi), 101);
    end
    
    properties (SetAccess = private)
        initGates = {};
        repeatGates = {};
        endGates = {};
	end
    
    methods
        function self = AzimuthCal(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.SweepM8195(pulseCal, config);
            self.histogram = 0;
        end
        
        function SetUp(self)
            self.sequences = pulselib.gateSequence();
            
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end           
            
            switch self.qubitGates{1}
                case 'Y180'
                    self.initGates = {'X90'};
                    self.repeatGates = {'Ym180', 'X180', 'Y180', 'X180'};
                    self.endGates = {'Y90'};
                case 'Y90'
                    self.initGates = {'X90'};
                    self.repeatGates = {'Ym90', 'Ym90', 'X180', 'Y90', 'Y90', 'X180'};
                    self.endGates = {'Y90'};
                case 'X90'
                    self.initGates = {'Y90'};
                    self.repeatGates = {'Xm90', 'Xm90', 'Y180', 'X90', 'X90', 'Y180'};
                    self.endGates = {'X90'};
				otherwise
					error('Unknown qubit gates');
            end
            
            for row = 1:length(self.azimuthVector)
                self.sequences(row) = pulselib.gateSequence();
                self.pulseCal.([self.qubitGates{1}, 'Azimuth']) = self.azimuthVector(row);
                for col = 1:length(self.initGates)
                    self.sequences(row).append(self.pulseCal.(self.initGates{col}));
                end
                for repeat = 1:self.numRepeats
                    for col = 1:length(self.repeatGates)
                        self.sequences(row).append(self.pulseCal.(self.repeatGates{col}));
                    end
                end
                for col = 1:length(self.endGates)
                    self.sequences(row).append(self.pulseCal.(self.endGates{col}));
                end
            end
            SetUp@explib.SweepM8195(self);
        end

        function Run(self)
            Run@explib.SweepM8195(self);
            self.Plot();
        end
        
        function Plot(self)
            figure(104);
            self.result.newAzimuth = funclib.AzimuthFit(self.azimuthVector, self.result.AmpInt);
            xlabel('Azimuth');
            ylabel('Readout amplitude');
            title([self.experimentName, ', azimuth: ', num2str(self.result.newAzimuth*(180/pi))]);
			drawnow;
        end
    end
end
        