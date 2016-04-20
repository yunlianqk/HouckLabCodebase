classdef rbSequence < handle
    % Randomized Benchmarking Sequence. Composed of an array of clifford gate
    % objects. 
    
    properties
        seqList; % list of clifford gates to be done in this sequence
        pulses; % cliffordGate object array, in order to be done
    end
    
    properties (Dependent, SetAccess = private)
        sequenceDuration;
        
    end
    
    properties (SetAcess = private)
        unitary;
    end
    
    methods
        function obj=rbSequence(seqList, cliffords)
            obj.seqList=seqList;
            for ind=1:length(seqList)
                pulses(ind)=cliffords(seqList(ind));
            end
            obj.pulses=pulses;
            % find unitary for sequence (before adding undo gate)
            unitary=[1 0; 0 1];
            for ind=1:(length(obj.pulses)-1)
                unitary=obj.pulses(ind).unitary*unitary;
            end
            obj.unitary=unitary;
            obj.undoGate(cliffords);
        end
        
        function value = get.sequenceDuration(obj)
            % find total time required for all the cliffords in this
            % sequence
            value=0;
            for ind=1:length(obj.pulses)
                value=value+obj.pulses(ind).totalGateDuration;
            end
        end
        
%         function value = get.unitary(obj)
            % find unitary for sequence (before adding undo gate)
%             value=[1 0; 0 1];
%             for ind=1:(length(obj.pulses)-1)
%                 value=obj.pulses(ind).unitary*value;
%             end
%         end
        
        function obj=undoGate(obj, cliffords)
            % finds undo gate and appends it to the sequence
            pulses = obj.pulses;
            G=obj.unitary;
%             G=[1 0; 0 1];
%             for ind=1:length(pulses)
%                 G=pulses(ind).unitary*G;
%             end
            U=G'; % undo gate unitary
            % compare undo gate to list of cliffords to find index
            for ind2=1:length(cliffords)                
                c=cliffords(ind2).unitary;
                if (abs(trace(c'*U))>=(2-1e-6)) % dimension of 2 hardcoded here... only works for 1 qubit
                    pulses(length(pulses)+1)=cliffords(ind2);
                    obj.seqList=[obj.seqList ind2];
                    test=cliffords(ind2);
                    test.unitary==U
                end
            end
            obj.pulses=pulses;
            if test.unitary
        end
        
        function [iBaseband qBaseband] = uwWaveforms(obj,tAxis, tStop)
            % given time axis and end time returns final baseband
            % signals. can be added to similar outputs from other gates to
            % form a composite waveform
            iBaseband=zeros(size(tAxis));
            qBaseband=zeros(size(tAxis));
            tStart = tStop-obj.sequenceDuration;
            for ind=1:length(obj.pulses)
                gate=obj.pulses(ind);
                [iTemp qTemp] = gate.uwWaveforms(tAxis,tStart);
                iBaseband=iBaseband+iTemp;
                qBaseband=qBaseband+qTemp;
                tStart=tStart+gate.totalGateDuration;
            end
        end
            
        function draw(obj) % visualize the gate
            % print some text
            fprintf(['Sequence length: ' num2str(length(obj.seqList)) '\n'])
            fprintf('Sequence unitary without undo gate:')
            unitary=[1 0; 0 1];
            for ind1=1:(length(obj.pulses)-1)
                gate=obj.pulses(ind1);
                unitary = gate.unitary*unitary;
            end
            unitary
            fprintf('Undo gate unitary')
            undo=obj.pulses(end).unitary
            fprintf('After undo')
            final=undo*unitary
            % draw bloch spheres - 1st w/out undo gate
            figure(612)
            ax=subplot(2,2,1);
            state=[1;0];
            blochSpherePlot(ax,0,0);
            for ind1=1:(length(obj.pulses)-1)
                gate=obj.pulses(ind1);
                [state, tilt, azimuth] = gate.actOnState(state);
                blochSpherePlot(ax,tilt,azimuth,'replot');
            end
            title('Sequence with Undo Gate')
            % with undo gate
            ax2=subplot(2,2,2);
            state=[1;0];
            blochSpherePlot(ax2,0,0);
            for ind1=1:length(obj.pulses)
                gate=obj.pulses(ind1);
                [state, tilt, azimuth] = gate.actOnState(state);
                blochSpherePlot(ax2,tilt,azimuth,'replot');
            end
            title('Sequence with Undo Gate')
            % draw basebands
            pulseStopTime = 0; % set to 0 for draw function purposes. 
            t = linspace(-obj.sequenceDuration,0,10001);
            [iBaseband qBaseband] = obj.uwWaveforms(t, pulseStopTime);
            subplot(2,1,2)
            plot(t,iBaseband,'b',t,qBaseband,'r')
            title('I and Q baseband waveforms')
            legend('I','Q')
            % find start times for each clifford and add to plot
            tStart=pulseStopTime-obj.sequenceDuration;
            cliffTimes=[];
            for ind2=1:length(obj.pulses)
                cliffTimes=[cliffTimes tStart];
                gate=obj.pulses(ind2);
                tStart=tStart+gate.totalGateDuration;
            end
            hold on, plot(cliffTimes,zeros(length(cliffTimes)),'.k','MarkerSize',20),hold off
            
%             subplot(2,4,[3,4,7,8])
%             scatter3(iBaseband, qBaseband,t,[],1:length(t),'.');
%             axis square;
%             plotMax=max([max(abs(iBaseband)) max(abs(qBaseband))]);tmax=max(t);
%             if plotMax==0
%                 plotMax=1;
%             end
%             axis([-plotMax plotMax -plotMax plotMax 0 tmax])
%             title(obj.name),xlabel('I'),ylabel('Q')
        end    
            
        
        
        
        
        
    end
end