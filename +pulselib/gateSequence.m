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
        function obj=gateSequence(gateArray)
            if nargin > 0
                obj.gateArray = gateArray;
            end
        end
        
        function value = get.totalSequenceDuration(obj)
            % find total time required for clifford
            value=0;
            for ind=1:length(obj.gateArray)
                value=value+obj.gateArray(ind).totalDuration;
            end
        end
        
        function value = get.totalUnitary(obj)
            % calculates overall effect of gate sequence
            unitary=[1 0; 0 1];
            for ind=1:length(obj.gateArray)
                unitary=obj.gateArray(ind).unitary*unitary;
            end
            value=unitary;
        end
            
        
        function [iBaseband qBaseband] = uwWaveforms(obj,tAxis, tStart)
            % given just a time axis and the time to begin, returns final baseband
            % signals. can be added to similar outputs from other gates to
            % form a composite waveform
            iBaseband=zeros(size(tAxis));
            qBaseband=zeros(size(tAxis));
            for ind=1:length(obj.gateArray)
                gate=obj.gateArray(ind);
                tCenter=tStart+gate.totalDuration/2;
                [iTemp qTemp] = gate.uwWaveforms(tAxis,tCenter);
                iBaseband=iBaseband+iTemp;
                qBaseband=qBaseband+qTemp;
                tStart=tStart+gate.totalDuration;
            end
        end
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(obj,stateIn)
            % given an input state vector act with unitary and return final state 
            stateOut=obj.totalUnitary*stateIn;
            stateTilt = 2*acos(abs(stateOut(1)));
            stateAzimuth = angle(stateOut(2))-angle(stateOut(1));
        end
        
        function draw(obj) % visualize the gate
            % print some text
            fprintf(['unitary rotation matrix:\n'])
            disp(obj.totalUnitary)
            % draw bloch spheres
            figure(612)
            ax=subplot(2,4,1);
            stateIn=[1;0];
            plotlib.blochSpherePlot(ax,0,0);
            [stateOut, stateTilt, stateAzimuth] = obj.actOnState(stateIn);
            plotlib.blochSpherePlot(ax,stateTilt,stateAzimuth,'replot');
            title('Sequence Behavior')
            ax2=subplot(2,4,2);
            state=[1;0];
            plotlib.blochSpherePlot(ax2,0,0);
            for ind1=1:length(obj.gateArray)
                pGate=obj.gateArray(ind1);
                [state, tilt, azimuth] = pGate.actOnState(state);
                plotlib.blochSpherePlot(ax2,tilt,azimuth,'replot');
            end
            title('Gate by Gate Behavior')
            % draw basebands
            pulseStartTime = 0; % set to 0 for draw function purposes. this is the end of the last 'buffer', so we'll start the buffer of this pulse here
            t = 0:1e-9:obj.totalSequenceDuration;
            [iBaseband qBaseband] = uwWaveforms(obj,t, pulseStartTime);
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
            
       
        