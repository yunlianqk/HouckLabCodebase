classdef gateSequence < handle
    % a set of gate objects to be done one after another.

    properties
        % cell array containing pulselib objects.
        gateArray = {};
    end

    properties (Dependent, SetAccess = private)
        totalDuration;
        totalUnitary; % a 2x2 matrix corresponding to the action of sequence
    end
    
    properties (Dependent, SetAccess = private, Hidden)
        % 'totalSequenceDuration' is deprecated. Use 'totalDuration' instead
        totalSequenceDuration;
    end

    methods
        function self = gateSequence(gateArray)
            if nargin > 0
                if ~iscell(gateArray)
                    gateArray = num2cell(gateArray);
                end
                for gate = gateArray
                    self.checkinput(gate{:});
                end
                self.gateArray = gateArray;
            end
        end

        function len = len(self)
            len = length(self.gateArray);
        end
        
        function value = get.totalDuration(self)
            % return total duration of the sequence
            value = 0;
            for gate = self.gateArray
                value = value + gate{:}.totalDuration;
            end
        end
        
        function value = get.totalSequenceDuration(self)
            % 'totalSequenceDuration' is deprecated. Use 'totalDuration' instead
            value = self.totalDuration;
        end
        
        function unitary = get.totalUnitary(self)
            % calculates overall effect of the sequence
            unitary = [1 0; 0 1];
            for gate = self.gateArray
                if isprop(gate{:}, 'unitary')
                    unitary = gate{:}.unitary*unitary;
                end
            end
        end

        function [iBaseband, qBaseband] = uwWaveforms(self, tAxis, tStart)
            % given time axis and start time, returns final baseband signals.

            iBaseband = zeros(size(tAxis));
            qBaseband = zeros(size(tAxis));
            % Loop through all the gates in sequence
            for gate = self.gateArray
                % Length of the current gate
                tGate = gate{:}.totalDuration;
                if isa(gate{:}, 'pulselib.delay') ...
                   || (isa(gate{:}, 'pulselib.singleGate') ...
                       && strcmp(gate{:}.name, 'Identity'))
                    % No need to calcuate waveforms if it is delay or identity
                else
                    % Only calculate waveforms if it is actually a gate
                    start = find(tAxis>=tStart, 1);
                    stop = find(tAxis<=tStart+tGate, 1, 'last');
                    % Replace the segment that covers the current gate
                    % with its waveforms
                    [iBaseband(start:stop), qBaseband(start:stop)] ...
                        = gate{:}.uwWaveforms(tAxis(start:stop), tStart);
                end
                tStart = tStart + tGate;
            end
        end
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(self, stateIn)
            % given an input state vector act with unitary and return final state 
            stateOut = self.totalUnitary*stateIn;
            stateTilt = 2*real(acos(abs(stateOut(1))));
            stateAzimuth = angle(stateOut(2))-angle(stateOut(1));
        end

        function draw(self) % visualize the gate
            % print some text
            display('unitary rotation matrix:');
            disp(self.totalUnitary)
            % draw bloch spheres
            figure(612);
            ax = subplot(2,4,1);
            stateIn=[1; 0];
            plotlib.blochSpherePlot(ax, 0, 0);
            [~, stateTilt, stateAzimuth] = self.actOnState(stateIn);
            plotlib.blochSpherePlot(ax, stateTilt, stateAzimuth, 'replot');
            title('Sequence Behavior');
            ax2 = subplot(2,4,2);
            state = [1; 0];
            plotlib.blochSpherePlot(ax2, 0, 0);
            for gate = self.gateArray
                try
                    [state, tilt, azimuth] = gate{:}.actOnState(state);
                catch
                end
                plotlib.blochSpherePlot(ax2, tilt, azimuth, 'replot');
            end
            title('Gate by Gate Behavior');
            % draw basebands
            pulseStartTime = 0; % set to 0 for draw function purposes. this is the end of the last 'buffer', so we'll start the buffer of this pulse here
            t = linspace(0, self.totalSequenceDuration, 5001);
            [iBaseband, qBaseband] = uwWaveforms(self, t, pulseStartTime);
            subplot(2, 4, [5, 6]);
            plot(t, iBaseband, 'b', t, qBaseband, 'r');
            title('I and Q baseband waveforms');
            legend('I', 'Q');
            subplot(2, 4, [3, 4, 7, 8]);
            scatter3(iBaseband, qBaseband, t, [], 1:length(t), '.');
            axis square;
            plotMax = max([max(abs(iBaseband)), max(abs(qBaseband))]);
            tmax = max(t);
            if plotMax == 0
                plotMax = 1;
            end
            axis([-plotMax plotMax -plotMax plotMax 0 tmax])
            title(' ');
            xlabel('I');
            ylabel('Q');
        end

        function append(self, gates)
            % append gates to the end of sequence
            if ~iscell(gates)
                gates = num2cell(gates);
            end
            for gate = gates
                self.checkinput(gate{:})
            end
            self.gateArray(end+1:end+length(gates)) = gates;
        end

        function gates = pop(self, idx)
            % get the gates with index=idx and remove it from sequence
            if nargin == 1
                idx = 1;
            end
            gates = self.gateArray{idx};
            self.gateArray(idx) = [];
        end

        function insert(self, idx, gates)
            % insert gates at index=idx
            if ~iscell(gates)
                gates = num2cell(gates);
            end
            for gate = gates
                self.checkinput(gate{:})
            end
            self.gateArray = [self.gateArray(1:idx-1), gates, self.gateArray(idx:end)];
        end

        function clear(self)
            % clear whole sequence
            self.gateArray = {};
        end

        function checkinput(~, gate)
            % check the input type
            if isempty(strfind(class(gate), 'pulselib'))
                error('Input must pulselib objects.');
            end
        end
    end
end
