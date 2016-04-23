classdef RBExperiment < handle
    %Randomized Benchmarking Experiment object for generating waveforms to
    %be sent to the awg. JJR 2016, Princeton
    
    properties
        primitives; % object array of primitive gates.
        cliffords; % object array of clifford gates.
        sequences; % object array of randomized benchmarking sequences
        sequenceLengths = [1 2 4 8 16 32]; % list containing number of clifford gates in each sequence
        measurement; % measurement pulse object
        rbStartTime = 200e-9; % delay in seconds before earliest clifford gate
        rbEndTime; % uses max rbSequence duration to caluclate
        measDelay = 50e-9; % time in seconds btw last clifford gate and start of measurement pulse 
        measStartTime; % starts shortly after end of the rbSequence 
        measEndTime;
        waveformEndDelay = 50e-9; % delay after end of measurement pulse to end waveform
        qubitFreq=5e9; % qubit frequency
        cavityFreq=7e9; % cavity frequency
        samplingRate=15e9; % sampling rate
    end
    
    methods
        function obj=RBExperiment()% constructor
            obj.initPrimitives();
            obj.initCliffords();
            obj.measurement=rectMeasurementPulse(0,1,1e-6);
            obj.initSequences();
        end
        
        function obj=set.sequenceLengths(obj,s)
            obj.sequenceLengths=s;
            obj.initSequences();
        end
        
        function obj=initPrimitives(obj)
            % general pulse parameters
            sigma=10e-9; % gaussian width in seconds
            cutoff=4*sigma;  % force pulse tail to zero. this is the total time the pulse is nonzero in seconds
            buffer=4e-9; % extra time beyond the cutoff to separate gates.  this is the total buffer, so half before and half after.
            % generate primitives
            amplitude=1;
            dragAmplitude=.5;
%             primitives(1)=gaussianWithDrag('Identity',0,0,0,0,sigma,cutoff,buffer);
%             primitives(2)=gaussianWithDrag('X180',0,pi,amplitude,dragAmplitude,sigma,cutoff,buffer);
%             primitives(3)=gaussianWithDrag('X90',0,pi/2,amplitude,dragAmplitude,sigma,cutoff,buffer);
%             primitives(4)=gaussianWithDrag('Xm90',0,-pi/2,amplitude,dragAmplitude,sigma,cutoff,buffer);
%             primitives(5)=gaussianWithDrag('Y180',pi/2,pi,amplitude,dragAmplitude,sigma,cutoff,buffer);
%             primitives(6)=gaussianWithDrag('Y90',pi/2,pi/2,amplitude,dragAmplitude,sigma,cutoff,buffer);
%             primitives(7)=gaussianWithDrag('Ym90',pi/2,-pi/2,amplitude,dragAmplitude,sigma,cutoff,buffer);
            primitives(1)=gaussianWithDrag('Identity',0,0,0,0,sigma,cutoff,buffer);
            primitives(2)=gaussianWithDrag('X180',0,pi,1,.5,sigma,cutoff,buffer);
            primitives(3)=gaussianWithDrag('X90',0,pi/2,.5,.25,sigma,cutoff,buffer);
            primitives(4)=gaussianWithDrag('Xm90',0,-pi/2,-.5,.25,sigma,cutoff,buffer);
            primitives(5)=gaussianWithDrag('Y180',pi/2,pi,.9,.3,sigma,cutoff,buffer);
            primitives(6)=gaussianWithDrag('Y90',pi/2,pi/2,.45,.15,sigma,cutoff,buffer);
            primitives(7)=gaussianWithDrag('Ym90',pi/2,-pi/2,-.45,.15,sigma,cutoff,buffer);
            obj.primitives=primitives;
        end
        
        function obj=initCliffords(obj) % generate object array of cliffords
            % call crazy code to randomly generate the decomposition of
            % cliffords into primitives.
            [cliffs,Clfrdstring]=SingleQubitCliffords();
            for ind1=1:length(cliffs)
                unitary=cliffs{ind1};
                primStrings=Clfrdstring{ind1};
                
                % traverse list of primitive names and find index for gate
                % object array
                primDecompInd = [];
                primDecomp = [];
                for ind2=1:length(primStrings)
                    if(strcmp(primStrings{ind2},'X90pPulse')==1)
                        primDecompInd = [primDecompInd 3];
                        primDecomp = [primDecomp obj.primitives(3)];
                    elseif(strcmp(primStrings{ind2},'X90mPulse')==1)
                        primDecompInd = [primDecompInd 4];
                        primDecomp = [primDecomp obj.primitives(4)];
                    elseif(strcmp(primStrings{ind2},'Y90pPulse')==1)
                        primDecompInd = [primDecompInd 6];
                        primDecomp = [primDecomp obj.primitives(6)];
                    elseif(strcmp(primStrings{ind2},'Y90mPulse')==1)
                        primDecompInd = [primDecompInd 7];
                        primDecomp = [primDecomp obj.primitives(7)];
                    elseif(strcmp(primStrings{ind2},'XpPulse')==1)
                        primDecompInd = [primDecompInd 2];
                        primDecomp = [primDecomp obj.primitives(2)];
                    elseif(strcmp(primStrings{ind2},'YpPulse')==1)
                        primDecompInd = [primDecompInd 5];
                        primDecomp = [primDecomp obj.primitives(5)];
                    elseif(strcmp(primStrings{ind2},'QIdPulse')==1)
                        primDecompInd = [primDecompInd 1];
                        primDecomp = [primDecomp obj.primitives(1)];
                    end
                end
                cliffords(ind1)=cliffordGate(ind1,unitary,primDecomp);
            end
            obj.cliffords=cliffords;
        end
        
        function obj=initSequences(obj)
            % using sequenceLengths, generate the sequence objects
            s = obj.sequenceLengths;
            [m, mInd]=max(s);
            numCliffords=length(obj.cliffords);
            
            % generate random sequence of cliffords with max sequenceLength
            rng('default');
            rng('shuffle');
            maxSequence = randi(numCliffords, [1,m]);
            
            % for each sequence length create a sequence object
            for ind=1:length(s)
                seqList=maxSequence(1:s(ind));
                % generate sequence object.  It will find and append the
                % proper undo gate.
                sequences(ind)=rbSequence(seqList,obj.cliffords);
            end
            obj.sequences=sequences;
            % find max duration of all sequences
            d=sequences(mInd).sequenceDuration;
            obj.rbEndTime=obj.rbStartTime+d;
            obj.measStartTime=obj.rbEndTime+obj.measDelay;
            obj.measEndTime=obj.measStartTime+obj.measurement.duration;
        end
        
        function draw(obj)
            t = 0:1/obj.samplingRate:(obj.measEndTime+obj.waveformEndDelay);
            figure(125)
            for ind=1:length(obj.sequences)
                seq=obj.sequences(ind);
                [iQubitBaseband qQubitBaseband] = seq.uwWaveforms(t, obj.rbEndTime);
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                subplot(2,1,1)
%                 plot(t,iQubitBaseband,'b',t,qQubitBaseband,'r')
%                 subplot(2,1,2)
%                 plot(t,iMeasBaseband,'b',t,qMeasBaseband,'r')
                plot(t,iQubitMod,'b',t,qQubitMod,'r')
                subplot(2,1,2)
                plot(t,iMeasMod,'b',t,qMeasMod,'r')
                
                pause(1)
            end
        end
        
    end
end
       