classdef X180DragCal< handle
    % Pi pulse error amplification for drag. After an initial pi/2 pulse it will
    % vary the number of subsequent pi pulses.  
    
    properties
        % change these to tweak the experiment
        experimentName = 'X180DragCal';
        numGateVector = 2:2:80;
        qubitFreq=4.772869998748302e9;
        qubitAmplitude = .7198;
        qubitDragAmplitude = .1;
        qubitSigma = 25e-9;
        gateType1 = 'X180'; % 1st of two opposite gates
        gateType2 = 'Xm180'; % 
        cavityFreq=10.16578e9; % cavity frequency
        cavityAmp=1;       % cavity pulse amplitude
        measDuration = 5e-6;
        measBuffer = 200e-9; % extra delay between end of last gate and start of measurement pulse
        startBuffer = 5e-6; % buffer at beginning of waveform
        endBuffer = 5e-9; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        pulse1; % 1st qubit pulse object
        pulse2; % 1st qubit pulse object
        sequences; % array of gateSequence objects
        measurement; % measurement pulse object
        measStartTime; 
        measEndTime;
        sequenceEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=X180DragCal()
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
            obj.pulse1 = pulselib.singleGate(obj.gateType1);
            obj.pulse1.amplitude = obj.qubitAmplitude;
            obj.pulse1.dragAmplitude = obj.qubitDragAmplitude;
            obj.pulse1.sigma = obj.qubitSigma;
            obj.pulse1.cutoff = obj.qubitSigma*4;
            obj.pulse2 = pulselib.singleGate(obj.gateType2);
            obj.pulse2.amplitude = obj.qubitAmplitude;
            obj.pulse2.dragAmplitude = obj.qubitDragAmplitude;
            obj.pulse2.sigma = obj.qubitSigma;
            obj.pulse2.cutoff = obj.qubitSigma*4;

            sequences(1,length(obj.numGateVector)) = pulselib.gateSequence(); % initialize empty array of gateSequence objects
            for ind = 1:length(obj.numGateVector)
                gateArray(1,obj.numGateVector(ind)) = pulselib.singleGate(); % init empty array of gate objects
                for ind2 = 1:obj.numGateVector(ind)
                    if mod(ind2,2) % if odd
                        gateArray(ind2) = obj.pulse1;
                    else
                        gateArray(ind2) = obj.pulse2;
                    end
                end
                sequences(ind)=pulselib.gateSequence(gateArray);
            end
            obj.sequences=sequences;
        end
        
        function playlist = directDownloadM8195A(obj,awg)
            % avoid building full wavesets and WaveLib to save memory 

            % clear awg of segments
            iqseq('delete', [], 'keepOpen', 1);
            % check # segments won't be too large
            if length(obj.numGateVector)>awg.maxSegNumber
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
            
            % generate LO and marker waveforms
            loWaveform = sin(2*pi*obj.cavityFreq*t);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            
            for ind=1:length(obj.sequences)
                display(['loading sequence ' num2str(ind)])
                s = obj.sequences(ind);
                tStart = obj.sequenceEndTime - s.totalSequenceDuration;
                [iQubitBaseband qQubitBaseband] = s.uwWaveforms(t, tStart);
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
            % last playlist item must have advance set to 'auto'
            playlist(backId).segmentAdvance = 'Auto';
        end
        
%         function w = genWaveset_M8195A(obj)
%             w = paramlib.M8195A.waveset();
%             tStep = 1/obj.samplingRate;
%             t = 0:tStep:(obj.waveformEndTime);
%             loWaveform = sin(2*pi*obj.cavityFreq*t);
%             markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
%             for ind=1:length(obj.sequences)
%                 s = obj.sequences(ind);
%                 tStart = obj.sequenceEndTime - s.totalSequenceDuration;
%                 [iQubitBaseband qQubitBaseband] = s.uwWaveforms(t, tStart);
%                 iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
%                 qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
%                 [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
%                 iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
%                 qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
%                 ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
%                 % background is measurement pulse to get contrast
%                 backgroundWaveform = iMeasMod+qMeasMod;
%                 s1=w.newSegment(ch1waveform,markerWaveform,[1 0; 0 0; 0 0; 0 0]);
%                 p1=w.newPlaylistItem(s1);
%                 % create LO segment with same id to play simultaneously
%                 s2=w.newSegment(loWaveform,markerWaveform,[0 0; 1 0; 0 0; 0 0]);
%                 s2.id = s1.id;
%                 % add background to playlist
%                 sBack = w.newSegment(backgroundWaveform,markerWaveform,[1 0; 0 0; 0 0; 0 0]);
%                 pBack = w.newPlaylistItem(sBack);
%                 % add lo to play @ same time as background
%                 s3=w.newSegment(loWaveform,markerWaveform,[0 0; 1 0; 0 0; 0 0]);
%                 s3.id = sBack.id;
%             end
%             % last playlist item must have advance set to 'auto'
%             pBack.advance='Auto';
%         end

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
                    subplot(2,3,1); imagesc(taxis,obj.numGateVector,Idata/ind);title(['In phase. N=' num2str(ind)]);ylabel('Number of Gates');xlabel('Time (\mus)');
                    subplot(2,3,2); imagesc(taxis,obj.numGateVector,Qdata/ind);title('Quad phase');ylabel('Number of Gates');xlabel('Time (\mus)');
                    subplot(2,3,4); imagesc(taxis,obj.numGateVector,Pdata/ind);title('Power I^2+Q^2');ylabel('Number of Gates');xlabel('Time (\mus)');
%                     subplot(2,3,5); imagesc(taxis,obj.numGateVector,phaseData/ind);title('Phase atan(Q/I)');ylabel('Delay');xlabel('Time (\mus)');
                    subplot(2,3,3); plot(obj.numGateVector,sqrt(Pint));ylabel('Power I^2+Q^2');xlabel('Number of Gates');
%                     subplot(2,3,6); plot(obj.numGateVector,phaseInt);ylabel('Integrated Phase');xlabel('Delay');
                    %                                 ax=subplot(2,3,3);
                    %                 try doing the T1 fit during softaveraging
                    %                 lambda = funclib.ExpFit(obj.delayList,sqrt(Pint),ax);
                    pause(0.01);
                end
                
            end
            result.taxis = taxis;
            result.Idata=Idata./softavg;
            result.Qdata=Qdata./softavg;
            result.Pdata=Pdata./softavg;
            result.Pint=Pint./softavg;
%             result.lambda=lambda;
            display('Experiment Finished')
        end


%         function [result] = runExperimentM8195A(obj,awg,card,cardparams)
%             % integration times
%             intStart=4000; intStop=8000;
%             % software averages
%             softavg=25;
%             w = obj.genWaveset_M8195A();
%             WaveLib = awg.WavesetExtractSegmentLibraryStruct(w);
%             PlayList = awg.WavesetExtractPlaylistStruct(w);
% %             w.drawSegmentLibrary()
% %             w.drawPlaylist()
% %             WaveLib = awg.ApplyCorrection(WaveLib);
%             awg.Wavedownload(WaveLib);
%             clear WaveLib;
%             cardparams.segments=length(w.playlist);
%             clear w;
%             cardparams.delaytime=obj.measStartTime-1e-6;
%             card.SetParams(cardparams);
%             tstep=1/card.params.samplerate;
%             taxis=(tstep:tstep:card.params.samples/card.params.samplerate)'./1e-6;%mus units
%             % READ
%             % intialize matrices
%             samples=uint64(cardparams.samples);
%             Idata=zeros(cardparams.segments/2,samples);
%             Qdata=zeros(cardparams.segments/2,samples);
%             Pdata=zeros(cardparams.segments/2,samples);
% %             phaseData=zeros(cardparams.segments/2,samples); 
%             for ind=1:softavg
%                 % "hardware" averaged I,I^2 data
%                 [tempI,tempI2,tempQ,tempQ2] = card.ReadIandQcomplicated(awg,PlayList);
%                 % software acumulation
%                 Idata=Idata+tempI;
%                 Qdata=Qdata+tempQ;
% %                 Pdata=Pdata+tempI2+tempQ2;
%                 Pdata=Idata.^2+Qdata.^2;
%                 Pint=mean(Pdata(:,intStart:intStop)');
% %                 phaseData = phaseData + atan(tempQ./tempI);
% %                 phaseInt = mean(phaseData(:,intStart:intStop)');
%                 
%                 if ~mod(ind,10)
%                     figure(101);
%                     subplot(2,3,1); imagesc(taxis,obj.numGateVector,Idata/ind);title(['In phase. N=' num2str(ind)]);ylabel('gates');xlabel('Time (\mus)');
%                     subplot(2,3,2); imagesc(taxis,obj.numGateVector,Qdata/ind);title('Quad phase');ylabel('AmpVector');xlabel('Time (\mus)');
%                     subplot(2,3,4); imagesc(taxis,obj.numGateVector,Pdata/ind);title('Power I^2+Q^2');ylabel('AmpVector');xlabel('Time (\mus)');
% %                     subplot(2,3,5); imagesc(taxis,obj.numGateVector,phaseData/ind);title('Phase atan(Q/I)');ylabel('AmpVector');xlabel('Time (\mus)');
%                     subplot(2,3,3); plot(obj.numGateVector,sqrt(Pint));ylabel('Homodyne Amplitude (V)');xlabel('Qubit pulse software amplitude');
% %                     subplot(2,3,6); plot(obj.numGateVector,phaseInt);ylabel('Integrated Phase');xlabel('Software Amplitude');
%                     pause(0.01);
%                 end
% %                 ax=subplot(2,2,4);
%                 % try doing the T1 fit during softaveraging
% %                 theta = funclib.RabiFit(taxis,Pdata,ax);
%             end
%             result.taxis = taxis;
%             result.Idata=Idata./softavg;
%             result.Qdata=Qdata./softavg;
%             result.Pdata=Pdata./softavg;
%             result.Pint=Pint./softavg;
%             display('Experiment Finished')
%             %             result.theta=theta;
%         end
        
    end
end
       