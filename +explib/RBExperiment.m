classdef RBExperiment < handle
    %Randomized Benchmarking Experiment object for generating waveforms to
    %be sent to the awg. JJR 2016, Princeton
    
    properties
        % change these to tweak the experiment
        experimentName = 'RandomizedBenchmark';
        sequenceLengths = [1 2 4 8 16 32 64 128]; % list containing number of clifford gates in each sequence. if you change this property it'll update the sequences
        qubitFreq=4.772869998748302e9;
        amp180 = .7198;
        drag180 = .015;
        amp90 = .3573;
        drag90 = .016;
        qubitSigma = 25e-9;
        cavityFreq=10.16578e9; % cavity frequency
        cavityAmp=1;       % cavity pulse amplitude
        measDuration = 5e-6;
        measBuffer = 200e-9; % extra delay between end of last gate and start of measurement pulse
        startBuffer = 5e-6; % buffer at beginning of waveform
        endBuffer = 5e-9; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        primitives; % object array of primitive gates.
        cliffords; % object array of clifford gates.
        sequences; % object array of randomized benchmarking sequences
        measurement; % measurement pulse object
        measStartTime; % starts shortly after end of the rbSequence 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=RBExperiment()% constructor
            obj.initPrimitives();
            obj.initCliffords();
            obj.measurement=pulselib.rectMeasurementPulse(0,1,1e-6);
            obj.initSequences();
        end
        
        function obj=set.sequenceLengths(obj,s)
            obj.sequenceLengths=s;
            obj.initSequences();
        end
        
        function obj=initPrimitives(obj)
            % general pulse parameters
            sigma=obj.qubitSigma; % gaussian width in seconds
            cutoff=4*sigma;  % force pulse tail to zero. this is the total time the pulse is nonzero in seconds
            buffer=4e-9; % extra time beyond the cutoff to separate gates.  this is the total buffer, so half before and half after.
            % generate primitives
            primitives(1)=pulselib.gaussianWithDrag('Identity',0,0,0,0,sigma,cutoff,buffer);
            primitives(2)=pulselib.gaussianWithDrag('X180',0,pi,.7198,.015,sigma,cutoff,buffer);
%             primitives(3)=pulselib.gaussianWithDrag('X90',0,pi/2,.3575,.25,sigma,cutoff,buffer);
%             primitives(4)=pulselib.gaussianWithDrag('Xm90',0,-pi/2,-.5,.25,sigma,cutoff,buffer);
%             primitives(5)=pulselib.gaussianWithDrag('Y180',pi/2,pi,.9,.3,sigma,cutoff,buffer);
            primitives(6)=pulselib.gaussianWithDrag('Y90',pi/2,pi/2,.45,.15,sigma,cutoff,buffer);
            primitives(7)=pulselib.gaussianWithDrag('Ym90',pi/2,-pi/2,-.45,.15,sigma,cutoff,buffer);
            obj.primitives=primitives;
        end
        
        function obj=initCliffords(obj) % generate object array of cliffords
            % call crazy code to randomly generate the decomposition of
            % cliffords into primitives.
            [cliffs,Clfrdstring]=explib.RB.SingleQubitCliffords();
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
                cliffords(ind1)=explib.RB.cliffordGate(ind1,unitary,primDecomp);
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
                sequences(ind)=explib.RB.rbSequence(seqList,obj.cliffords);
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
            figure(125);
            h1=subplot(2,1,1);
            hold(h1,'on');
            h2=subplot(2,1,2);
            hold(h2,'on');
            for ind=1:length(obj.sequences)
                seq=obj.sequences(ind);
                [iQubitBaseband qQubitBaseband] = seq.uwWaveforms(t, obj.rbEndTime);
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                
                plot(h1,t,iQubitMod+ind*2.5,'b',t,qQubitMod+ind*2.5,'r')
                plot(h2,t,iMeasMod+ind*2.5,'b',t,qMeasMod+ind*2.5,'r')
            end
            
        end
        
        function ws = genWaveSetM8195A(obj,seq)
            % take an rbSequence object (seq) and build a waveSet object that can
            % be sent to the M8195A AWG
            
            % generate qubit and measurement waveforms
            t = 0:1/obj.samplingRate:(obj.measEndTime+obj.waveformEndDelay);
            [iQubitBaseband qQubitBaseband] = seq.uwWaveforms(t, obj.rbEndTime);
            iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
            qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
            qubitWaveform=iQubitMod+qQubitMod;
            [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
            iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
            qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
            measWaveform=iMeasMod+qMeasMod;
            % build waveSet object
            ws=paramlib.M8195A.waveset();
            ws.samplingRate=obj.samplingRate;
            ws.addChannel(1,qubitWaveform);
            ws.addChannel(2,measWaveform);
        end
    end
end
       