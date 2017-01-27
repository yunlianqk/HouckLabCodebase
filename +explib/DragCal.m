classdef DragCal < explib.SweepM8195
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
            self = self@explib.SweepM8195(pulseCal, config);
            self.histogram = 0;
        end
        
        function SetUp(self)
            gates = pulselib.singleGate();
            self.sequences = pulselib.gateSequence();
            
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end

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
                self.sequences(row) = pulselib.gateSequence(gates);
            end
            SetUp@explib.SweepM8195(self);
        end

        function Run(self)
            Run@explib.SweepM8195(self);
            self.Plot();
        end
        
        function Plot(self)
            figure(103);
            self.result.newDragAmp = funclib.DragFit(self.dragVector, self.result.AmpInt);
            xlabel('Drag amplitude');
            ylabel('Readout amplitude');
            title([self.experimentName, ', DRAG amplitude: ', num2str(self.result.newDragAmp)]);
			drawnow;
        end
    end
end        