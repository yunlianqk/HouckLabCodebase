classdef T1Experiment < handle
    % T1 Experiment. X pulse with varying delay. JJR 2016, Princeton
    
    
    properties
        % change these to tweak the experiment
        qubitFreq=4.772869998748302e9;
        qubitAmp = .74;
        qubitSigma = 25e-9;
        gateType = 'X180';
%         delayList = 200e-9:1e-6:100.2e-6; % delay btw qubit pulses and measurement pulse
        delayList = 200e-9:1e-6:10.2e-6; % delay btw qubit pulses and measurement pulse
        cavityFreq=10.16578e9; % cavity frequency
        cavityAmp=1;       % cavity pulse amplitude
        measDuration = 5e-6;
        startBuffer = 5e-6; % buffer at beginning of waveform
        endBuffer = 5e-6; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        qubit; % qubit pulse object
        measurement; % measurement pulse object
        qubitPulseTimes; % calculated times for when pulses should occur (tCenter)
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=T1Experiment()
            % constructor generates the necessary objects and calculates the dependent parameters
            % generate qubit object
            obj.qubit = pulselib.singleGate(obj.gateType);
            obj.qubit.amplitude = obj.qubitAmp;
            obj.qubit.sigma = obj.qubitSigma;
            obj.qubit.cutoff = 4*obj.qubitSigma;
            % generate measurement pulse
            obj.measurement=pulselib.measPulse(obj.measDuration,obj.cavityAmp);
            % calculate measurement pulse times - based on the max
            % delay btw qubit and measurement
            obj.measStartTime = obj.startBuffer + max(obj.delayList);
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
            % calculate qubit pulse times based on the measurement time and
            % the desired delays
            for ind = 1:length(obj.delayList)
                obj.qubitPulseTimes(ind)=obj.measStartTime-obj.delayList(ind);
            end
        end
        
        function w = genWaveset_M8195A(obj)
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
            loWaveform = sin(2*pi*obj.cavityFreq*t);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            for ind=1:length(obj.delayList)
                q=obj.qubit;
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTimes(ind));
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
        
        function playlist = directDownloadM8195A(obj,awg)
            % avoid building full wavesets and WaveLib to save memory 

            % clear awg of segments
            iqseq('delete', [], 'keepOpen', 1);
            % check # segments won't be too large
            if length(obj.delayList)>awg.maxSegNumber
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
            
            for ind=1:length(obj.delayList)
                display(['loading delayList index: ' num2str(ind)])
                q=obj.qubit;
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTimes(ind));
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
                clear iQubitBaseband
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
            phaseData=zeros(cardparams.segments/2,samples); 
            for i=1:softavg
                % "hardware" averaged I,I^2 data
                [tempI,tempI2,tempQ,tempQ2] = card.ReadIandQcomplicated(awg,playlist);
                % software acumulation
                Idata=Idata+tempI;
                Qdata=Qdata+tempQ;
%                 Pdata=Pdata+tempI2+tempQ2;
                Pdata=Idata.^2+Qdata.^2;
                Pint=mean(Pdata(:,intStart:intStop)');
                phaseData = phaseData + atan(tempQ./tempI);
                phaseInt = mean(phaseData(:,intStart:intStop)');
                
                figure(101);
                subplot(2,3,1); imagesc(taxis,obj.delayList,Idata/i);title(['In phase. N=' num2str(i)]);ylabel('Delay');xlabel('Time (\mus)');
                subplot(2,3,2); imagesc(taxis,obj.delayList,Qdata/i);title('Quad phase');ylabel('Delay');xlabel('Time (\mus)');
                subplot(2,3,4); imagesc(taxis,obj.delayList,Pdata/i);title('Power I^2+Q^2');ylabel('Delay');xlabel('Time (\mus)');
                subplot(2,3,5); imagesc(taxis,obj.delayList./1e9,phaseData/i);title('Phase atan(Q/I)');ylabel('Delay');xlabel('Time (\mus)');
%                 subplot(2,3,3); plot(obj.delayList,sqrt(Pint));ylabel('Power I^2+Q^2');xlabel('Delay');
                subplot(2,3,6); plot(obj.delayList./1e9,phaseInt);ylabel('Integrated Phase');xlabel('Delay');
                                ax=subplot(2,3,3);
%                 try doing the T1 fit during softaveraging
%                 fitResult = funclib.ExpFit2(obj.delayList,sqrt(Pint)/i,ax);
                fitResult.lambda = funclib.ExpFit(obj.delayList,sqrt(Pint)/i,ax);
                fitResult.amp=0;
                title(ax,['amp: ' num2str(fitResult.amp) ' T1: ' num2str(fitResult.lambda)])
                pause(0.01);
            end
            result.taxis = taxis;
            result.Idata=Idata./softavg;
            result.Qdata=Qdata./softavg;
            result.Pdata=Pdata./softavg;
            result.Pint=Pint./softavg;
            result.lambda=fitResult.lambda;
            display('Experiment Finished')
        end
        
%         
%         function [result] = runExperimentM8195A(obj,awg,card,cardparams)
%             % integration times
%             intStart=4000; intStop=8000;
%             % software averages
%             softavg=200;
%             w = obj.genWaveset_M8195A();
%             WaveLib = awg.WavesetExtractSegmentLibraryStruct(w);
%             PlayList = awg.WavesetExtractPlaylistStruct(w);
% %             w.drawSegmentLibrary()
% %             w.drawPlaylist()
% %             WaveLib = awg.ApplyCorrection(WaveLib);
%             awg.Wavedownload(WaveLib);
%             cardparams.segments=length(w.playlist);
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
%             phaseData=zeros(cardparams.segments/2,samples); 
%             for i=1:softavg
%                 % "hardware" averaged I,I^2 data
%                 [tempI,tempI2,tempQ,tempQ2] = card.ReadIandQcomplicated(awg,PlayList);
%                 % software acumulation
%                 Idata=Idata+tempI;
%                 Qdata=Qdata+tempQ;
% %                 Pdata=Pdata+tempI2+tempQ2;
%                 Pdata=Idata.^2+Qdata.^2;
%                 Pint=mean(Pdata(:,intStart:intStop)');
%                 phaseData = phaseData + atan(tempQ./tempI);
%                 phaseInt = mean(phaseData(:,intStart:intStop)');
%                 
%                 figure(101);
%                 subplot(2,3,1); imagesc(taxis,obj.delayList,Idata/i);title(['In phase. N=' num2str(i)]);ylabel('Delay');xlabel('Time (\mus)');
%                 subplot(2,3,2); imagesc(taxis,obj.delayList,Qdata/i);title('Quad phase');ylabel('Delay');xlabel('Time (\mus)');
%                 subplot(2,3,4); imagesc(taxis,obj.delayList,Pdata/i);title('Power I^2+Q^2');ylabel('Delay');xlabel('Time (\mus)');
%                 subplot(2,3,5); imagesc(taxis,obj.delayList./1e9,phaseData/i);title('Phase atan(Q/I)');ylabel('Delay');xlabel('Time (\mus)');
% %                 subplot(2,3,3); plot(obj.delayList,sqrt(Pint));ylabel('Power I^2+Q^2');xlabel('Delay');
%                 subplot(2,3,6); plot(obj.delayList./1e9,phaseInt);ylabel('Integrated Phase');xlabel('Delay');
%                                 ax=subplot(2,3,3);
% %                 try doing the T1 fit during softaveraging
% %                 fitResult = funclib.ExpFit2(obj.delayList,sqrt(Pint)/i,ax);
%                 fitResult.lambda = funclib.ExpFit(obj.delayList,sqrt(Pint)/i,ax);
%                 fitResult.amp = [];
%                 pause(0.01);
%             end
%             result.taxis = taxis;
%             result.Idata=Idata./softavg;
%             result.Qdata=Qdata./softavg;
%             result.Pdata=Pdata./softavg^2;
%             result.Pint=Pint./softavg^2;
%             result.lambda=fitResult.lambda;
%             result.fitAmp=fitResult.amp;
%             display('Experiment Finished')
%         end
        
    end
end
       