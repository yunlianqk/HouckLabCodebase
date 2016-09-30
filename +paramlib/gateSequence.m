classdef gateSequence < handle
    % a set of gate objects to be done one after another.

    properties
        % cell array containing pulselib objects.
        gateArray = {};
    end

    properties (Dependent, SetAccess = private)
        totalSequenceDuration;
        totalUnitary; % a 2x2 matrix corresponding to the action of sequence
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

        function len = length(self)
            len = length(self.gateArray);
        end
        
        function value = get.totalSequenceDuration(self)
            % return total duration of the sequence
            value = 0;
            for gate = self.gateArray
                value = value + gate{:}.totalDuration;
            end
        end
        
        function unitary = get.totalUnitary(self)
            % calculates overall effect of the sequence
            unitary = [1 0; 0 1];
            for gate = self.gateArray
                unitary = gate{:}.unitary*unitary;
            end
        end

        function [iBaseband, qBaseband] = uwWaveforms(self, tAxis, tStart)
            % given time axis and start time, returns final baseband signals.
            % NOTE: provides speedup over slow version by passing small 
            % segments of tAxis to "iqSegment" method of each gate
            
            iBaseband = zeros(size(tAxis));
            qBaseband = zeros(size(tAxis));
            % Loop through all the gates in sequence
            for gate = self.gateArray
                % Length of the current gate
                tGate = gate{:}.totalDuration;
                if ~ismember(gate{:}.name, {'Identity', 'Delay'})
                    % Only calculate waveforms if it's actually a gate
                    start = find(tAxis>=tStart, 1);
                    stop = find(tAxis<=tStart+tGate, 1, 'last');
                    % Replace the segment that covers the current gate
                    % with its waveforms
                    [iBaseband(start:stop), qBaseband(start:stop)] ...
                        = gate{:}.iqSegment(tAxis(start:stop), tStart);
                end
                tStart = tStart + tGate;
            end
        end
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(self, stateIn)
            % given an input state vector act with unitary and return final state 
            stateOut = self.totalUnitary*stateIn;
            stateTilt = 2*acos(abs(stateOut(1)));
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
                [state, tilt, azimuth] = gate{:}.actOnState(state);
                plotlib.blochSpherePlot(ax2, tilt, azimuth, 'replot');
            end
            title('Gate by Gate Behavior');
            % draw basebands
            pulseStartTime = 0; % set to 0 for draw function purposes. this is the end of the last 'buffer', so we'll start the buffer of this pulse here
            t = 0:1e-9:self.totalSequenceDuration;
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

        function append(self, gate)
            % append a gate to the end of sequence
            self.checkinput(gate);
            self.gateArray{end+1} = gate;
        end

        function extend(self, gateList)
            % append a list of gates to the end of sequence
            if ~iscell(gateList)
                gateList = num2cell(gateList);
            end
            for gate = gateList
                self.checkinput(gate{:})
            end
            self.gateArray(end+1:end+length(gateList)) = gateList;
        end

        function gate = pop(self, idx)
            % get the gate with index=idx and remove it from sequence
            if nargin == 1
                idx = 1;
            end
            gate = self.gateArray{idx};
            self.gateArray(idx) = [];
        end

        function insert(self, idx, gate)
            % insert a gate at index=idx
            self.checkinput(gate);
            self.gateArray = {self.gateArray{1:idx-1}, gate, self.gateArray{idx:end}};
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