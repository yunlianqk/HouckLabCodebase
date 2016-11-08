classdef gateSequence < handle
    % a set of gate objects to be done one after another.
    
    properties
        gateArray; % object array containing primitive gate objects.  These are actually handles to the RBExperiments.primitives objects
    end
    
    properties (Dependent, SetAccess = private)
        totalSequenceDuration;
        totalUnitary; % a 2x2 matrix corresponding to the action of the clifford
    end
    
    methods
        function self=gateSequence(gateArray)
            if nargin > 0
                self.gateArray = gateArray;
            end
        end
        
        function value = get.totalSequenceDuration(self)
            % find total time required for clifford
            value=0;
            for ind=1:length(self.gateArray)
                value=value+self.gateArray(ind).totalDuration;
            end
        end
        
        function value = get.totalUnitary(self)
            % calculates overall effect of gate sequence
            unitary=[1 0; 0 1];
            for ind=1:length(self.gateArray)
                unitary=self.gateArray(ind).unitary*unitary;
            end
            value=unitary;
        end
            
        
        function [iBaseband, qBaseband] = uwWaveforms(self,tAxis, tStart)
            % given just a time axis and the time to begin, returns final baseband
            % signals. can be added to similar outputs from other gates to
            % form a composite waveform
            % NOTE: this method will be slow if used directly with a very
            % long waveform with high sampling rate.
            iBaseband=zeros(size(tAxis));
            qBaseband=zeros(size(tAxis));
            for ind=1:length(self.gateArray)
                gate=self.gateArray(ind);
                if ~strcmp(gate.name,'Identity') % only calc waveforms if it's actually a gate.
                    tCenter=tStart+gate.totalDuration/2;
                    [iTemp qTemp] = gate.uwWaveforms(tAxis,tCenter);
                    iBaseband=iBaseband+iTemp;
                    qBaseband=qBaseband+qTemp;
                end
                tStart=tStart+gate.totalDuration;
            end
        end
        
%         %%%%%%%%%%% has a bug in it...
%         function [iMod, qMod] = modWaveforms(self,tAxis, tStart, qubitFreq)
%             % speed up waveform generation by doing avoiding doing
%             % modulation on entire long waveform.
%             iMod=zeros(size(tAxis));
%             qMod=zeros(size(tAxis));
%             for ind=1:length(self.gateArray)
%                 gate=self.gateArray(ind);
%                 if ~strcmp(gate.name,'Identity') % only calc waveforms if it's actually a gate.
%                     tCenter=tStart+gate.totalDuration/2;
%                     [iTemp qTemp] = gate.modWaveforms(tAxis,tCenter,qubitFreq);
%                     iMod=iMod+iTemp;
%                     qMod=qMod+qTemp;
%                 end
%                 tStart=tStart+gate.totalDuration;
%             end
%         end
        
%         function [iBaseband, qBaseband] = uwWaveforms(self,tAxis, tStart)
%             % given just a time axis and the time to begin, returns final baseband
%             % signals. can be added to similar outputs from other gates to
%             % form a composite waveform
%             % NOTE: provides speedup over slow version by using small
%             % waveforms during intermediate calculations
%             samplingRate = 1/(tAxis(2)-tAxis(1));
%             tStop = tStart + self.totalSequenceDuration;
%             % calculate start and stop indices for nonzero elements.  includes boundary if it falls on a sample
%             startInd = ceil(tStart*samplingRate);
%             stopInd = floor(tStop*samplingRate);
%             % vector of nonzero indices
%             nonZeroInd = startInd:stopInd;
%             % vector of nonzero times
%             nonZeroTimeAxis = (nonZeroInd-1)/samplingRate;
%             % use short time axis to calculate the pulse waveform
%             [iBasebandShort, qBasebandShort] = uwWaveformsSlow(self, nonZeroTimeAxis, tStart);
%             % place short pulse vector into large vector of zeros
%             iBaseband = zeros(1,length(tAxis));
%             iBaseband(startInd:stopInd)=iBasebandShort;
%             qBaseband = zeros(1,length(tAxis));
%             qBaseband(startInd:stopInd)=qBasebandShort;
%         end
        
%         function [iBaseband, qBaseband, startInd, stopInd] = uwWaveFormsFast(self, samplingRate, tStart)
%             % Generates short time vector based on sampling rate.  Returns
%             % the short waveform vector along with the indicies to be used 
%             % to add/insert the short waveform into a longer waveform based
%             % on the full time axis. This version never actually handles
%             % long vectors.
%             % example usage of outputs:  longWaveform(indStart:indStop) = longWaveform(indStart:indStop) + iBaseband;
%             tStop = tStart + self.totalSequenceDuration;
%             % calculate start and stop indices for nonzero elements.  includes boundary if it falls on a sample
%             startInd = ceil(tStart*samplingRate);
%             stopInd = floor(tStop*samplingRate);
%             % generate short vectors of zeros to be populated by gates
%             iBaseband = zeros(1,stopInd-startInd+1);
%             qBaseband = zeros(1,stopInd-startInd+1);
%             % loop through gates and use uwWaveformsFast to generate and insert them
%             for ind=1:length(self.gateArray)
%                 gate=self.gateArray(ind);
%                 if ~strcmp(gate.name,'Identity') % only calc waveforms if it's actually a gate.
%                     tCenter=tStart+gate.totalDuration/2;
%                     [iTemp, qTemp, gateStartInd, gateStopInd] = gate.uwWaveformsFast(samplingRate, tCenter);
%                     iBaseband(gateStartInd:gateStopInd) = iBaseband(gateStartInd:gateStopInd) + iTemp;
%                     qBaseband(gateStartInd:gateStopInd) = qBaseband(gateStartInd:gateStopInd) + qTemp;
%                 end
%                 tStart=tStart+gate.totalDuration;
%             end
%         end
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(self,stateIn)
            % given an input state vector act with unitary and return final state 
            stateOut=self.totalUnitary*stateIn;
            stateTilt = 2*acos(abs(stateOut(1)));
            stateAzimuth = angle(stateOut(2))-angle(stateOut(1));
        end
        
        function draw(self) % visualize the gate
            % print some text
            fprintf(['unitary rotation matrix:\n'])
            disp(self.totalUnitary)
            % draw bloch spheres
            figure(612)
            ax=subplot(2,4,1);
            stateIn=[1;0];
            plotlib.blochSpherePlot(ax,0,0);
            [stateOut, stateTilt, stateAzimuth] = self.actOnState(stateIn);
            plotlib.blochSpherePlot(ax,stateTilt,stateAzimuth,'replot');
            title('Sequence Behavior')
            ax2=subplot(2,4,2);
            state=[1;0];
            plotlib.blochSpherePlot(ax2,0,0);
            for ind1=1:length(self.gateArray)
                pGate=self.gateArray(ind1);
                [state, tilt, azimuth] = pGate.actOnState(state);
                plotlib.blochSpherePlot(ax2,tilt,azimuth,'replot');
            end
            title('Gate by Gate Behavior')
            % draw basebands
            pulseStartTime = 0; % set to 0 for draw function purposes. this is the end of the last 'buffer', so we'll start the buffer of this pulse here
            t = 0:1e-9:self.totalSequenceDuration;
            [iBaseband qBaseband] = uwWaveforms(self,t, pulseStartTime);
            subplot(2,4,[5,6])
            plot(t,iBaseband,'b',t,qBaseband,'r')
            title('I and Q baseband waveforms')
            legend('I','Q')
            subplot(2,4,[3,4,7,8])
            scatter3(iBaseband, qBaseband,t,[],1:length(t),'.');
            axis square;
            plotMax=max([max(abs(iBaseband)) max(abs(qBaseband))]);tmax=max(t);
            if plotMax==0
                plotMax=1;
            end
            axis([-plotMax plotMax -plotMax plotMax 0 tmax])
            title(' '),xlabel('I'),ylabel('Q')
        end
    end
end
            
       
        