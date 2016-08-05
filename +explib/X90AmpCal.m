classdef X90AmpCal< handle
    % Pi pulse error amplification. After an initial pi/2 pulse it will
    % vary the number of subsequent pi pulses.  
    
    properties
        % change these to tweak the experiment
        numGateVector = 2:2:40;
        qubitFreq=4.772869998748302e9;
        qubitAmplitude = .5;
        qubitSigma = 18e-9;
        iGateType = 'X90'; % initial gate (currently just use a half power pi pulse... need to rethink how this should be done after calibrations!)
        gateType = 'X90'; % repeated gate type 
        iGateAmplitude = .5;
        iGateSigma = 18e-9;
        cavityFreq=10.16578e9; % cavity frequency
        cavityAmp=1;       % cavity pulse amplitude
        measDuration = 5e-6;
        measBuffer = 200e-9; % extra delay between end of last gate and start of measurement pulse
        startBuffer = 5e-6; % buffer at beginning of waveform
        endBuffer = 5e-9; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        iGate; % initial qubit pulse object
        mainGate; % qubit pulse object
        sequences; % array of gateSequence objects
        measurement; % measurement pulse object
        measStartTime; 
        measEndTime;
        sequenceEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=X90AmpCal()
            % constructor generates the necessary objects and calculates the dependent parameters
            obj.initSequences(); % init routine to build gate sequences
            
            % generate measurement pulse
            obj.measurement=pulselib.measPulse(obj.measDuration, obj.cavityAmp);
            
            % calculate measurement pulse time - based on the max number of
            % gates
            seqDurations = [obj.sequences.totalSequenceDuration];
            maxSeqDuration = max(seqDurations);
            obj.measStartTime = obj.startBuffer + maxSeqDuration + obj.measBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
            % gate sequence end times are all the same. start times can be
            % calculated on the fly
            obj.sequenceEndTime = obj.measStartTime-obj.measBuffer;
        end
        
        function obj=initSequences(obj)
            % generate qubit objects
            obj.iGate= pulselib.singleGate(obj.gateType);
            obj.iGate.amplitude = obj.iGateAmplitude;
            obj.iGate.sigma= obj.iGateSigma;
            obj.iGate.cutoff = obj.iGateSigma*4;
            obj.mainGate = pulselib.singleGate(obj.gateType);
            obj.mainGate.amplitude = obj.qubitAmplitude;
            obj.mainGate.sigma = obj.qubitSigma;
            obj.mainGate.cutoff = obj.qubitSigma*4;
            
            sequences(1,length(obj.numGateVector)) = pulselib.gateSequence(); % initialize empty array of gateSequence objects
            for ind = 1:length(obj.numGateVector)
                gateArray(1,obj.numGateVector(ind)) = pulselib.singleGate(); % init empty array of gate objects
                gateArray(1)=obj.iGate;
                for ind2 = 1:obj.numGateVector(ind)
                    gateArray(ind2+1) = obj.mainGate;
                end
                sequences(ind)=pulselib.gateSequence(gateArray);
            end
            obj.sequences=sequences;
        end
        
        function w = genWaveset_M8195A(obj)
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
            loWaveform = sin(2*pi*obj.cavityFreq*t);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            for ind=1:length(obj.sequences)
                s = obj.sequences(ind);
                tStart = obj.sequenceEndTime - s.totalSequenceDuration;
                [iQubitBaseband qQubitBaseband] = s.uwWaveforms(t, tStart);
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
                % background is measurement pulse to get contrast
                backgroundWaveform = iMeasMod+qMeasMod;
                s1=w.newSegment(ch1waveform,markerWaveform,[1 0; 0 0; 0 0; 0 0]);
                p1=w.newPlaylistItem(s1);
                % create LO segment with same id to play simultaneously
                s2=w.newSegment(loWaveform,markerWaveform,[0 0; 1 0; 0 0; 0 0]);
                s2.id = s1.id;
                % add background to playlist
                sBack = w.newSegment(backgroundWaveform,markerWaveform,[1 0; 0 0; 0 0; 0 0]);
                pBack = w.newPlaylistItem(sBack);
                % add lo to play @ same time as background
                s3=w.newSegment(loWaveform,markerWaveform,[0 0; 1 0; 0 0; 0 0]);
                s3.id = sBack.id;
            end
            % last playlist item must have advance set to 'auto'
            pBack.advance='Auto';
        end
        
        function [result] = runExperimentM8195A(obj,awg,card,cardparams)
            % integration times
            intStart=4000; intStop=8000;
            % software averages
            softavg=100;
            w = obj.genWaveset_M8195A();
            WaveLib = awg.WavesetExtractSegmentLibraryStruct(w);
            PlayList = awg.WavesetExtractPlaylistStruct(w);
%             w.drawSegmentLibrary()
%             w.drawPlaylist()
%             WaveLib = awg.ApplyCorrection(WaveLib);
            awg.Wavedownload(WaveLib);
            clear WaveLib;
            cardparams.segments=length(w.playlist);
            clear w;
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
            phaseData=zeros(cardparams.segments/2,samples); 
            for i=1:softavg
                % "hardware" averaged I,I^2 data
                [tempI,tempI2,tempQ,tempQ2] = card.ReadIandQcomplicated(awg,PlayList);
                % software acumulation
                Idata=Idata+tempI;
                Qdata=Qdata+tempQ;
%                 Pdata=Pdata+tempI2+tempQ2;
                Pdata=Idata.^2+Qdata.^2;
                Pint=mean(Pdata(:,intStart:intStop)');
                phaseData = phaseData + atan(tempQ./tempI);
                phaseInt = mean(phaseData(:,intStart:intStop)');
                
                figure(101);
                subplot(2,3,1); imagesc(taxis,obj.numGateVector,Idata/i);title(['In phase. N=' num2str(i)]);ylabel('gates');xlabel('Time (\mus)');
                subplot(2,3,2); imagesc(taxis,obj.numGateVector,Qdata/i);title('Quad phase');ylabel('AmpVector');xlabel('Time (\mus)');
                subplot(2,3,4); imagesc(taxis,obj.numGateVector,Pdata/i);title('Power I^2+Q^2');ylabel('AmpVector');xlabel('Time (\mus)');
                subplot(2,3,5); imagesc(taxis,obj.numGateVector,phaseData/i);title('Phase atan(Q/I)');ylabel('AmpVector');xlabel('Time (\mus)');
                subplot(2,3,3); plot(obj.numGateVector,sqrt(Pint));ylabel('Homodyne Amplitude (V)');xlabel('Qubit pulse software amplitude');
                subplot(2,3,6); plot(obj.numGateVector,phaseInt);ylabel('Integrated Phase');xlabel('Software Amplitude');
                pause(0.01);
%                 ax=subplot(2,2,4);
                % try doing the T1 fit during softaveraging
%                 theta = funclib.RabiFit(taxis,Pdata,ax);
            end
            result.taxis = taxis;
            result.Idata=Idata./softavg;
            result.Qdata=Qdata./softavg;
            result.Pdata=Pdata./softavg;
            result.Pint=Pint./softavg;
            display('Experiment Finished')
            %             result.theta=theta;
        end
        
    end
end
       