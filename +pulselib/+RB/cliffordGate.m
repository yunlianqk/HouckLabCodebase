classdef cliffordGate < handle
    % Clifford gate which is a composite of some primitive gates.
    
    properties
        name; % string generated using index of generated clifford
        unitary; % a 2x2 matrix corresponding to the action of the clifford
        primDecomp; % object array containing primitive gate objects.  These are actually handles to the RBExperiments.primitives objects
        primString; % cellstr containing the name of primitive gates.
    end
    
    properties (Dependent, SetAccess = private)
        totalGateDuration;
    end
    
    methods
        function self = cliffordGate(index, unitary, primDecomp)
            self.name = ['C', num2str(index)];
            self.unitary = unitary;
            self.primDecomp = primDecomp;
            self.primString = {};
            for ind = 1:length(self.primDecomp)
                self.primString{ind} = self.primDecomp(ind).name;
            end
        end
        
        function value = get.totalGateDuration(self)
            value = sum([self.primDecomp.totalDuration]);
        end
        
        function [iBaseband, qBaseband] = uwWaveforms(self, tAxis, tStart)
            % given just a time axis and the time to begin, returns final baseband
            % signals. can be added to similar outputs from other gates to
            % form a composite waveform
            iBaseband = zeros(size(tAxis));
            qBaseband = zeros(size(tAxis));
            for ind = 1:length(self.primDecomp)
                gate = self.primDecomp(ind);
                tCenter = tStart + gate.totalDuration/2;
                [iTemp, qTemp] = self.primDecomp(ind).uwWaveforms(tAxis, tCenter);
                iBaseband = iBaseband + iTemp;
                qBaseband = qBaseband + qTemp;
                tStart = tStart + gate.totalDuration;
            end
        end
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(self, stateIn)
            % given an input state vector act with unitary and return final state 
            stateOut = self.unitary*stateIn;
            stateTilt = 2*acos(abs(stateOut(1)));
            stateAzimuth = angle(stateOut(2)) - angle(stateOut(1));
        end
        
        function draw(self) % visualize the gate
            % print some text
            fprintf(['Clifford name: ', self.name, '\n']);
            fprintf(['Decomposition: ', [self.primDecomp.name], '\n']);
%             fprintf(['rotation: ' num2str(obj.rotation) '\n'])
            fprintf('unitary rotation matrix:\n');
            disp(self.unitary);
            % draw bloch spheres
            figure(612)
            ax = subplot(2,4,1);
            stateIn = [1;0];
            plotlib.blochSpherePlot(ax,0,0);
            [stateOut, stateTilt, stateAzimuth] = self.actOnState(stateIn);
            plotlib.blochSpherePlot(ax,stateTilt,stateAzimuth,'replot');
            title(self.name);
            ax2=subplot(2,4,2);
            state=[1;0];
            plotlib.blochSpherePlot(ax2,0,0);
            for ind1=1:length(self.primDecomp)
                pGate=self.primDecomp(ind1);
                [state, tilt, azimuth] = pGate.actOnState(state);
                plotlib.blochSpherePlot(ax2,tilt,azimuth,'replot');
            end
            title([self.primDecomp.name]);
            % draw basebands
            pulseStartTime = 0; % set to 0 for draw function purposes. thiss is the end of the last 'buffer', so we'll start the buffer of this pulse here
            t = linspace(0,self.totalGateDuration,1001);
            [iBaseband, qBaseband] = uwWaveforms(self,t, pulseStartTime);
            subplot(2,4,[5,6]);
            plot(t,iBaseband,'b',t,qBaseband,'r');
            title('I and Q baseband waveforms');
            legend('I','Q');
            subplot(2,4,[3,4,7,8]);
            scatter3(iBaseband, qBaseband,t,[],1:length(t),'.');
            axis square;
            plotMax = max([max(abs(iBaseband)), max(abs(qBaseband))]);
            tmax = max(t);
            if plotMax == 0
                plotMax = 1;
            end
            axis([-plotMax, plotMax, -plotMax, plotMax, 0, tmax]);
            title(self.name);
            xlabel('I');
            ylabel('Q');
        end
    end
end