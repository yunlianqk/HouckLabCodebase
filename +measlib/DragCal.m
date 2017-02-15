classdef DragCal < measlib.SmartSweep
    % DRAG calibration for single qubit gates
    
    % 'qubitGates' is a cellstr that contains the name of gate
    % e.g., qubitGates = {'X180'} or qubitGates = {'X90'}, etc.
    % 'dragVector' is an array that contains the drag amplitudes in the sweep
    % the drag amplitude values should be between 0 and 1
    % 'numRepeats' determines how many pairs of positive/negative rotations
    % are concatenated to amplify DRAG error
    
    % Example:
    % qubitGates = {'X180'}, numRepeats = 3, dragVector = linspace(-0.5, 0.5, 101)
    % will generate a gate sequence (X180*Xm180)^3
    % and sweep dragAmp from -0.5 to 0.5 in 101 steps
    % The result should be a cosine like curve with maximum ground state
    % population at optimal dragAmp
    
    properties
        qubitGates = {'X180'};
        numRepeats = 3;
        dragVector = linspace(-0.5, 0.5, 101);
    end
    
    methods
        function self = DragCal(pulseCal, config)
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
            
            % Construct gate sequences
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end
            
            gates = pulselib.singleGate();
            self.gateseq = pulselib.gateSequence();
            for row = 1:length(self.dragVector)
                for col = 1:self.numRepeats
                    % Positive rotation
                    gates(2*col-1) = self.pulseCal.(self.qubitGates{1});
                    % Set drag amplitude
                    gates(2*col-1).dragAmplitude = self.dragVector(row);
                    % Negative rotation
                    gates(2*col) = self.pulseCal.([self.qubitGates{1}(1), 'm', ...
                                                   self.qubitGates{1}(2:end)]);
                    % Set drag amplitude
                    gates(2*col).dragAmplitude = self.dragVector(row);
                end
                % Construct sequences
                self.gateseq(row) = pulselib.gateSequence(gates);
            end
            % Construct measurement pulse
            self.measpulse = self.pulseCal.measurement();
            
            self.result.rowAxis = self.dragVector;
            SetUp@measlib.SmartSweep(self);
        end
        
        function Fit(self, fignum)
            if nargin == 1
                fignum = 101;
            end
            self.Integrate();
            self.Normalize();
            figure(fignum);
            self.result.newDragAmp = funclib.DragFit(self.dragVector, self.result.ampI);
            xlabel('Drag amplitude');
            ylabel('P(|1>)');
            title(['DRAG amplitude: ', num2str(self.result.newDragAmp)]);
        end
    end
end        