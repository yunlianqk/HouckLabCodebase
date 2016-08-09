classdef RabiExperiment < handle
    % Simple Rabi Experiment. X pulse with varying power. JJR 2016, Princeton

    properties 
        % change these to tweak the experiment. 
        experimentName = 'RabiExperiment';
        qubitFreq=4.772869998748302e9;
%         startAmp=.7198;
%         stopAmp=0;
        startAmp=1;
        stopAmp=0;
        points = 101;
        gateType = 'X180';
        qubitSigma = 25e-9; % qubit pulse sigma
        qubitDragAmplitude = .015;
%         interPulseBuffer = 200e-9; % time between qubit pulse and measurement pulse
        interPulseBuffer = 1000e-9; % time between qubit pulse and measurement pulse
        cavityFreq=10.16578e9; % cavity frequency
        cavityAmp=1;       % cavity pulse amplitude
        measDuration = 10e-6;
        measStartTime = 5e-6; 
        endBuffer = 5e-6; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        ampVector
        qubit; % qubit pulse object
        qubitPulseTime;
        measurement; % measurement pulse object
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=RabiExperiment()
            % constructor generates the necessary objects and calculates the dependent parameters
            obj.qubit = pulselib.singleGate(obj.gateType);
            obj.qubit.sigma = obj.qubitSigma;
            obj.qubit.cutoff = 4*obj.qubitSigma;
            obj.qubit.dragAmplitude = obj.qubitDragAmplitude;
            obj.measurement=pulselib.measPulse(obj.measDuration,obj.cavityAmp);
            obj.ampVector = linspace(obj.startAmp,obj.stopAmp,obj.points);
            obj.qubitPulseTime = obj.measStartTime - obj.interPulseBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
        end
        
        function playlist = directDownloadM8195A(obj,awg)
            % avoid building full wavesets and WaveLib to save memory 

            % clear awg of segments
            iqseq('delete', [], 'keepOpen', 1);
            % check # segments won't be too large
            if length(obj.ampVector)>awg.maxSegNumber
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
            
            for ind=1:obj.points
                display(['loading sequence ' num2str(ind)])
                q = obj.qubit;
                q.amplitude=obj.ampVector(ind);
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTime);
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
        
        function [result] = directRunM8195A(obj,awg,card,cardparams,playlist)
            % some hardware specific settings
            intStart=1; intStop=10000; % integration times
            softavg=100; % software averages
            % auto update some card settings
            cardparams.segments=length(playlist);
%             cardparams.delaytime=obj.measStartTime-1e-6;
            cardparams.delaytime=obj.measStartTime-1e-6+2.5e-6;
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
                figure(101);
                h=subplot(2,3,1);
                set(h,'Visible','off');
                someText = {obj.experimentName,['softavg = 0']};
                th=text(.1,.9,someText);
                if ~mod(ind,10)
                    figure(101);
                    someText = {obj.experimentName,['softavg = ' num2str(ind)]};
                    subplot(2,3,1);
                    delete(th)
                    th=text(.1,.9,someText);
                    subplot(2,3,2); imagesc(taxis,obj.ampVector,Idata/ind);title('In phase');ylabel('Amplitude');xlabel('Time (\mus)');
                    subplot(2,3,3); imagesc(taxis,obj.ampVector,Qdata/ind);title('Quad phase');ylabel('Amplitude');xlabel('Time (\mus)');
                    subplot(2,3,4); imagesc(taxis,obj.ampVector,Pdata/ind);title('Power I^2+Q^2');ylabel('Amplitude');xlabel('Time (\mus)');
                    subplot(2,3,[5 6]); plot(obj.ampVector,sqrt(Pint));ylabel('Sqrt(Power) I^2+Q^2');xlabel('Amplitude');
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
        
%         function w = genWaveset_M8195A(obj)
%             w = paramlib.M8195A.waveset();
%             tStep = 1/obj.samplingRate;
%             t = 0:tStep:(obj.waveformEndTime);
%             loWaveform = sin(2*pi*obj.cavityFreq*t);
%             markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
% %             backgroundWaveform = zeros(1,length(t));
%             for ind=1:obj.points
%                 q=obj.qubit;
%                 q.amplitude=obj.ampVector(ind);
%                 [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTime);
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
        
%         function [result] = runExperimentM8195A(obj,awg,card,cardparams)
%             % integration times
%             intStart=4000; intStop=8000;
%             % software averages
%             softavg=100;
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
%                 subplot(2,3,1); imagesc(taxis,obj.ampVector,Idata/i);title(['In phase. N=' num2str(i)]);ylabel('AmpVector');xlabel('Time (\mus)');
%                 subplot(2,3,2); imagesc(taxis,obj.ampVector,Qdata/i);title('Quad phase');ylabel('AmpVector');xlabel('Time (\mus)');
%                 subplot(2,3,4); imagesc(taxis,obj.ampVector,Pdata/i);title('Power I^2+Q^2');ylabel('AmpVector');xlabel('Time (\mus)');
%                 subplot(2,3,5); imagesc(taxis,obj.ampVector./1e9,phaseData/i);title('Phase atan(Q/I)');ylabel('AmpVector');xlabel('Time (\mus)');
%                 subplot(2,3,3); plot(obj.ampVector,sqrt(Pint));ylabel('Homodyne Amplitude (V)');xlabel('Qubit pulse software amplitude');
%                 subplot(2,3,6); plot(obj.ampVector./1e9,phaseInt);ylabel('Integrated Phase');xlabel('Software Amplitude');
%                 pause(0.01);
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
       