classdef cliffordGate < handle
    %clifford gate which is a composite of some primitive gates.
    
    properties
        name; % string generated using index of generated clifford
        unitary; % a 2x2 matrix corresponding to the action of the clifford
        primDecomp; % object array containing primitive gate objects.  These are actually handles to the RBExperiments.primitives objects
    end
    
    properties (Dependent, SetAccess = private)
        totalGateDuration;
    end
    
    methods
        function obj=cliffordGate(index,unitary, primDecomp)
            obj.name = ['C' num2str(index)];
            obj.unitary=unitary;
            obj.primDecomp=primDecomp;
        end
        
        function value = get.totalGateDuration(obj)
            % find total time required for clifford
            value=0;
            for ind=1:length(obj.primDecomp)
                value=value+obj.primDecomp(ind).totalPulseDuration;
            end
            
        end
        
        function [iBaseband qBaseband] = uwWaveforms(obj,tAxis, tStart)
            % given just a time axis and the time to begin, returns final baseband
            % signals. can be added to similar outputs from other gates to
            % form a composite waveform
            iBaseband=zeros(size(tAxis));
            qBaseband=zeros(size(tAxis));
            for ind=1:length(obj.primDecomp)
                gate=obj.primDecomp(ind);
                tCenter=tStart+gate.totalPulseDuration/2;
                [iTemp qTemp] = obj.primDecomp(ind).uwWaveforms(tAxis,tCenter);
                iBaseband=iBaseband+iTemp;
                qBaseband=qBaseband+qTemp;
                tStart=tStart+gate.totalPulseDuration;
            end
        end
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(obj,stateIn)
            % given an input state vector act with unitary and return final state 
            stateOut=obj.unitary*stateIn;
            stateTilt = 2*acos(abs(stateOut(1)));
            stateAzimuth = angle(stateOut(2))-angle(stateOut(1));
        end
        
        function draw(obj) % visualize the gate
            % print some text
            fprintf(['Clifford name: ' obj.name '\n'])
            fprintf(['Decomposition: ' [obj.primDecomp.name] '\n'])
%             fprintf(['rotation: ' num2str(obj.rotation) '\n'])
            fprintf(['unitary rotation matrix:\n'])
            disp(obj.unitary)
            % draw bloch spheres
            figure(612)
            ax=subplot(2,4,1);
            stateIn=[1;0];
            blochSpherePlot(ax,0,0);
            [stateOut, stateTilt, stateAzimuth] = obj.actOnState(stateIn);
            blochSpherePlot(ax,stateTilt,stateAzimuth,'replot');
            title(obj.name)
            ax2=subplot(2,4,2);
            state=[1;0];
            blochSpherePlot(ax2,0,0);
            for ind1=1:length(obj.primDecomp)
                pGate=obj.primDecomp(ind1);
                [state, tilt, azimuth] = pGate.actOnState(state);
                blochSpherePlot(ax2,tilt,azimuth,'replot');
            end
            title([obj.primDecomp.name])
            % draw basebands
            pulseStartTime = 0; % set to 0 for draw function purposes. thiss is the end of the last 'buffer', so we'll start the buffer of this pulse here
            t = linspace(0,obj.totalGateDuration,1001);
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
            title(obj.name),xlabel('I'),ylabel('Q')
        end
    end
end
            
       
        