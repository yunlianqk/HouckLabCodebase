classdef rbSequence < handle
    % Randomized Benchmarking Sequence. Composed of an array of clifford gate
    % objects. 
    
    properties
        seqList; % list of clifford gates to be done in this sequence
        pulses; % cliffordGate object array, in order to be done
        unitary; % action of rbseequence w/out undo gate
        undoUnitary; % the action of the final pulse that is supposed to bring it back to the ground state
    end
    
    properties (Dependent, SetAccess = private)
        sequenceDuration;
    end
    
    methods
        function obj=rbSequence(seqList, cliffords)
            % generate the rbSequence object.
            % inputs - seqList: a vector of #s corresponding the which cliffords to do (i.e. the 'sequence') 
            % cliffords is an array of clifford gate objects 
            obj.seqList=seqList;
            for ind=1:length(seqList)
                pulses(ind)=cliffords(seqList(ind));
            end
            obj.pulses=pulses;
            % find unitary for sequence (before adding undo gate)
            unitary=[1 0; 0 1];
            for ind=1:length(seqList)
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
        
        function obj=undoGate(obj, cliffords)
            % finds undo gate and appends it to the sequence
            pulses = obj.pulses;
            G=obj.unitary;
            U=G';
            % compare undo gate to list of cliffords to find index
            for ind=1:length(cliffords)                
                c=cliffords(ind).unitary;
                if (abs(trace(c*G))>=(2-1e-6)) % dimension of 2 hardcoded here... only works for 1 qubit
                    pulses(length(pulses)+1)=cliffords(ind);
                    obj.seqList=[obj.seqList ind];
                    obj.undoUnitary=c;
                    break
                end
            end
            obj.pulses=pulses;
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
            obj.unitary
            fprintf('Undo gate unitary')
            undo=obj.pulses(end).unitary
            fprintf('After undo')
            final=undo*obj.unitary
            
            % add some text to a subplot
            figure(612)
            textAx = subplot(2, 3, 3);
            cla(textAx)
            infoStr={'rbSequence Object','',...
                     'gates',[obj.pulses.name],...
                     };
            text(0,1,infoStr);
            set( textAx, 'visible', 'off')
           
            % draw bloch spheres - 1st w/out undo gate
            ax=subplot(2,3,1);
            state=[1;0];
            plotlib.blochSpherePlot(ax,0,0);
            for ind1=1:(length(obj.pulses)-1)
                gate=obj.pulses(ind1);
                [state, tilt, azimuth] = gate.actOnState(state);
                plotlib.blochSpherePlot(ax,tilt,azimuth,'replot');
            end
            title('Sequence without Undo Gate')
            % with undo gate
            ax2=subplot(2,3,2);
            state=[1;0];
            plotlib.blochSpherePlot(ax2,0,0);
            for ind1=1:length(obj.pulses)
                gate=obj.pulses(ind1);
                [state, tilt, azimuth] = gate.actOnState(state);
                plotlib.blochSpherePlot(ax2,tilt,azimuth,'replot');
            end
            title('Sequence with Undo Gate')
            % draw basebands
            pulseStopTime = 0; % set to 0 for draw function purposes. 
            t = linspace(-obj.sequenceDuration,0,10001);
            [iBaseband qBaseband] = obj.uwWaveforms(t, pulseStopTime);
            subplot(2,3,[4,5,6])
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
            
            % add some text to a subplot

        end    
            
        
        
        
        
        
    end
end