classdef DragExperiment < explib.SweepM8195
    % Simple DRAG sweep. qubit gates with varying drag amplitude
    
    % 'qubitGates' is a cellstr that contains the names of gates
    % e.g., qubitGates = {'X180', 'Xm180'} or qubitGates = {'X90', 'Xm90'}, etc.
    % 'dragVector' is an array that contains the drag amplitudes in the sweep
    % the drag amplitude values should be between 0 and 1

    properties
        qubitGates = {'X180', 'Xm180'};
        dragVector = linspace(-0.5, 0.5, 101);
    end
    
    methods
        function self = DragExperiment(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.SweepM8195(pulseCal, config);
            self.histogram = 0;
        end
        
        function SetUp(self)
            sweepgates = pulselib.singleGate();
            self.sequences = pulselib.gateSequence();
            
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end

            for row = 1:length(self.dragVector)
                for col = 1:length(self.qubitGates)
                    % Construct qubit gates
                    sweepgates(col) = pulselib.singleGate(self.qubitGates{col}, self.pulseCal);
                    % Vary drag amplitude
                    sweepgates(col).dragAmplitude = self.dragVector(row);
                end
                % Construct sequences
                self.sequences(row) = pulselib.gateSequence(sweepgates);
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
            title([self.experimentName, ', new DRAG amplitude: ', num2str(self.result.newDragAmp)]);
        end
    end
end
        