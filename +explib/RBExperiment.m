classdef RBExperiment < handle
    % Randomized Benchmarking Experiment object for generating waveforms to
    % be sent to the awg. JJR 2016, Princeton
    
    properties
        % change these to tweak the experiment
        experimentName = 'RandomizedBenchmark';
%         sequenceLengths = 1:4:41; % list containing number of clifford gates in each sequence. if you change this property it'll update the sequences
%         sequenceLengths = [1 2 4 8 16 32 64 128 256]; % list containing number of clifford gates in each sequence. if you change this property it'll update the sequences
        sequenceLengths = [2 3 4 5 6 8 10 12 16 20 24 32 40 48 64 80 96]; % This is from Jerry's thesis pg 155
        %         sequenceLengths = [1 2 4 8 16]; % list containing number of clifford gates in each sequence. if you change this property it'll update the sequences
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
        endBuffer = 5e-6; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        primitives; % object array of primitive gates.
        cliffords; % object array of clifford gates.
        sequences; % object array of randomized benchmarking sequences
        measurement; % measurement pulse object
        rbEndTime;
        measStartTime; % starts shortly after end of the rbSequence 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=RBExperiment()% constructor
            obj.initPrimitives();
            obj.initCliffords();
            obj.measurement=pulselib.measPulse(obj.measDuration, obj.cavityAmp);
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
            primitives(2)=pulselib.gaussianWithDrag('X180',0,pi,obj.amp180,obj.drag180,sigma,cutoff,buffer);
            primitives(3)=pulselib.gaussianWithDrag('X90',0,pi/2,obj.amp90,obj.drag90,sigma,cutoff,buffer);
            primitives(4)=pulselib.gaussianWithDrag('Xm90',0,-pi/2,-obj.amp90,-obj.drag90,sigma,cutoff,buffer);
            primitives(5)=pulselib.gaussianWithDrag('Y180',pi/2,pi,obj.amp180,obj.drag180,sigma,cutoff,buffer);
            primitives(6)=pulselib.gaussianWithDrag('Y90',pi/2,pi/2,obj.amp90,obj.drag90,sigma,cutoff,buffer);
            primitives(7)=pulselib.gaussianWithDrag('Ym90',pi/2,-pi/2,-obj.amp90,-obj.drag90,sigma,cutoff,buffer);
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
            obj.rbEndTime=obj.startBuffer+d;
            obj.measStartTime=obj.rbEndTime+obj.measBuffer;
            obj.measEndTime=obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime + obj.endBuffer;
        end
        
        function draw(obj)
            t = 0:1/obj.samplingRate:(obj.waveformEndTime);
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %M8195A Direct Download Specific Code
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function playlist = directDownloadM8195A(obj,awg)
            % avoid building full wavesets and WaveLib to save memory 
            % also adding 0 and pi pulse after sequence for normalization
                        
            % clear awg of segments
            iqseq('delete', [], 'keepOpen', 1);
            % check # segments won't be too large
            if length(obj.sequenceLengths+2)>awg.maxSegNumber
                error(['Waveform library size exceeds maximum segment number ',int2str(awg.maxSegNumber)]);
            end

            % set up time axis and make sure it's correct length for awg
            tStep = 1/obj.samplingRate;
            waveformLength = floor(obj.waveformEndTime/tStep)+1;
            paddedLength = ceil(waveformLength/awg.granularity)*awg.granularity;
            paddedWaveformEndTime = (paddedLength-1)*tStep;
            % check if too short
            if paddedLength < awg.minSegSize
                error(['Time axis is too short. Min segment size: ',int2str(awg.minSegSize)]);
            end
            % check if too long
            if paddedLength > awg.maxSegSize
                error(['Time axis is larger than maximum segment size ',int2str(awg.maxSegSize)]);
            end
            % create time axis with correct # size
            t = 0:tStep:paddedWaveformEndTime;            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % generate LO and marker waveforms
            loWaveform = sin(2*pi*obj.cavityFreq*t);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            
            for ind=1:length(obj.sequences)
                display(['loading sequence ' num2str(ind)])
                s = obj.sequences(ind);
                % RB Sequence object takes END time as an input!
                [iQubitBaseband qQubitBaseband] = s.uwWaveforms(t, obj.rbEndTime);
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
                clear iQubitBaseband;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
                clear qQubitBaseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                clear iMeasBaseband 
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                clear qMeasBaseband;
                ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
                clear iQubitMod qQubitMod
                % background is measurement pulse to get contrast
                backgroundWaveform = iMeasMod+qMeasMod;
                clear iMeasMod qMeasMod
                
                % now directly loading into awg
                dataId = ind*2-1;
                backId = ind*2;
                % load data segment
                iqdownload(ch1waveform,awg.samplerate,'channelMapping',[1 0; 0 0; 0 0; 0 0],'segmentNumber',dataId,'keepOpen',1,'run',0,'marker',markerWaveform);
                clear ch1waveform;
                % load lo segment
                iqdownload(loWaveform,awg.samplerate,'channelMapping',[0 0; 1 0; 0 0; 0 0],'segmentNumber',dataId,'keepOpen',1,'run',0,'marker',markerWaveform);
                % create data playlist entry
                playlist(dataId).segmentNumber = dataId;
                playlist(dataId).segmentLoops = 1;
                playlist(dataId).markerEnable = true;
                playlist(dataId).segmentAdvance = 'Stepped';
                % load background segment
                iqdownload(backgroundWaveform,awg.samplerate,'channelMapping',[1 0; 0 0; 0 0; 0 0],'segmentNumber',backId,'keepOpen',1,'run',0,'marker',markerWaveform);
                clear backgroundWaveform;
                % load lo segment
                iqdownload(loWaveform,awg.samplerate,'channelMapping',[0 0; 1 0; 0 0; 0 0],'segmentNumber',backId,'keepOpen',1,'run',0,'marker',markerWaveform);
                % create background playlist entry
                playlist(backId).segmentNumber = backId;
                playlist(backId).segmentLoops = 1;
                playlist(backId).markerEnable = true;
                playlist(backId).segmentAdvance = 'Stepped';
            end
            
            % now that sequences are loaded, add the 0
            % pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            display('loading normalization I pulse');
            ig = obj.primitives(1);
            tCenter = obj.rbEndTime - ig.totalPulseDuration/2;
            [iQubitBaseband qQubitBaseband] = ig.uwWaveforms(t, tCenter);
            iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
            clear iQubitBaseband;
            qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
            clear qQubitBaseband;
            [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
            iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
            clear iMeasBaseband
            qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
            clear qMeasBaseband;
            ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
            clear iQubitMod qQubitMod
            % background is measurement pulse to get contrast
            backgroundWaveform = iMeasMod+qMeasMod;
            clear iMeasMod qMeasMod
            
            % now directly loading into awg
            dataId = ind*2+1;
            backId = ind*2+2;
            % load data segment
            iqdownload(ch1waveform,awg.samplerate,'channelMapping',[1 0; 0 0; 0 0; 0 0],'segmentNumber',dataId,'keepOpen',1,'run',0,'marker',markerWaveform);
            clear ch1waveform;
            % load lo segment
            iqdownload(loWaveform,awg.samplerate,'channelMapping',[0 0; 1 0; 0 0; 0 0],'segmentNumber',dataId,'keepOpen',1,'run',0,'marker',markerWaveform);
            % create data playlist entry
            playlist(dataId).segmentNumber = dataId;
            playlist(dataId).segmentLoops = 1;
            playlist(dataId).markerEnable = true;
            playlist(dataId).segmentAdvance = 'Stepped';
            % load background segment
            iqdownload(backgroundWaveform,awg.samplerate,'channelMapping',[1 0; 0 0; 0 0; 0 0],'segmentNumber',backId,'keepOpen',1,'run',0,'marker',markerWaveform);
            clear backgroundWaveform;
            % load lo segment
            iqdownload(loWaveform,awg.samplerate,'channelMapping',[0 0; 1 0; 0 0; 0 0],'segmentNumber',backId,'keepOpen',1,'run',0,'marker',markerWaveform);
            % create background playlist entry
            playlist(backId).segmentNumber = backId;
            playlist(backId).segmentLoops = 1;
            playlist(backId).markerEnable = true;
            playlist(backId).segmentAdvance = 'Stepped';
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            display('loading normalization X180 pulse');
            ig = obj.primitives(2);
            tCenter = obj.rbEndTime - ig.totalPulseDuration/2;
            [iQubitBaseband qQubitBaseband] = ig.uwWaveforms(t, tCenter);
            iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
            clear iQubitBaseband;
            qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
            clear qQubitBaseband;
            [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
            iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
            clear iMeasBaseband
            qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
            clear qMeasBaseband;
            ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
            clear iQubitMod qQubitMod
            % background is measurement pulse to get contrast
            backgroundWaveform = iMeasMod+qMeasMod;
            clear iMeasMod qMeasMod
            
            % now directly loading into awg
            dataId = ind*2+3;
            backId = ind*2+4;
            % load data segment
            iqdownload(ch1waveform,awg.samplerate,'channelMapping',[1 0; 0 0; 0 0; 0 0],'segmentNumber',dataId,'keepOpen',1,'run',0,'marker',markerWaveform);
            clear ch1waveform;
            % load lo segment
            iqdownload(loWaveform,awg.samplerate,'channelMapping',[0 0; 1 0; 0 0; 0 0],'segmentNumber',dataId,'keepOpen',1,'run',0,'marker',markerWaveform);
            % create data playlist entry
            playlist(dataId).segmentNumber = dataId;
            playlist(dataId).segmentLoops = 1;
            playlist(dataId).markerEnable = true;
            playlist(dataId).segmentAdvance = 'Stepped';
            % load background segment
            iqdownload(backgroundWaveform,awg.samplerate,'channelMapping',[1 0; 0 0; 0 0; 0 0],'segmentNumber',backId,'keepOpen',1,'run',0,'marker',markerWaveform);
            clear backgroundWaveform;
            % load lo segment
            iqdownload(loWaveform,awg.samplerate,'channelMapping',[0 0; 1 0; 0 0; 0 0],'segmentNumber',backId,'keepOpen',1,'run',0,'marker',markerWaveform);
            % create background playlist entry
            playlist(backId).segmentNumber = backId;
            playlist(backId).segmentLoops = 1;
            playlist(backId).markerEnable = true;
            % last playlist item must have advance set to 'auto'
            playlist(backId).segmentAdvance = 'Auto';
        end
        
        function [result] = directRunM8195A(obj,awg,card,cardparams,playlist)
            % some hardware specific settings
            intStart=4000; intStop=8000; % integration times
            softavg=50; % software averages
            % auto update some card settings
            cardparams.segments=length(playlist);
            cardparams.delaytime=obj.measStartTime-1e-6;
            card.SetParams(cardparams);
            tstep=1/card.params.samplerate;
            taxis=(tstep:tstep:card.params.samples/card.params.samplerate)'./1e-6;%mus units
            % READ
            % intialize matrices
            samples=uint64(cardparams.samples);
            Idata=zeros(cardparams.segments/2,samples);
            Qdata=zeros(cardparams.segments/2,samples);
            Pdata=zeros(cardparams.segments/2,samples);
%             phaseData=zeros(cardparams.segments/2,samples); 
            for ind=1:softavg
                % "hardware" averaged I,I^2 data
                [tempI,tempI2,tempQ,tempQ2] = card.ReadIandQcomplicated(awg,playlist);
                % software acumulation
                Idata=Idata+tempI;
                Qdata=Qdata+tempQ;
%                 Pdata=Pdata+tempI2+tempQ2;
                Pdata=Idata.^2+Qdata.^2;
                Pint=mean(Pdata(:,intStart:intStop)');
%                 phaseData = phaseData + atan(tempQ./tempI);
%                 phaseInt = mean(phaseData(:,intStart:intStop)');
                
                if ~mod(ind,10)
                    figure(101);
                    h=subplot(2,3,1);
                    set(h,'Visible','off');
                    someText = {obj.experimentName,['softavg = ' num2str(ind)]};
                    text(.1,.9,someText);
                    subplot(2,3,2); imagesc(taxis,[1 length(obj.sequenceLengths)],Idata/ind);title('In phase');ylabel('Subsequence Index');xlabel('Time (\mus)');
                    subplot(2,3,3); imagesc(taxis,[1 length(obj.sequenceLengths)],Qdata/ind);title('Quad phase');ylabel('Subsequence Index');xlabel('Time (\mus)');
                    subplot(2,3,4); imagesc(taxis,[1 length(obj.sequenceLengths)],Pdata/ind);title('Power I^2+Q^2');ylabel('Subsequence Index');xlabel('Time (\mus)');
%                     subplot(2,3,[5 6]); plot(obj.sequenceLengths,sqrt(Pint));ylabel('Power I^2+Q^2');xlabel('Number of Gates');
                    subplot(2,3,[5 6]); plot(sqrt(Pint));ylabel('sqrt(Power) I^2+Q^2');xlabel('Number of Gates');
                    drawnow
                end
                
            end
            result.taxis = taxis;
            result.Idata=Idata./softavg;
            result.Qdata=Qdata./softavg;
            result.Pdata=Pdata./softavg;
            result.Pint=Pint./softavg;
            display('Experiment Finished')
        end
        
        
    end
end
       