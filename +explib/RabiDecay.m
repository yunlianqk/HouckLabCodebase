classdef RabiDecay < handle
    % T1 Experiment. X pulse with varying delay. JJR 2016, Princeton
    
    
    properties
        pulseCal;
        experimentName = 'RabiDecay'
        durationList = 47e-9:.5e-6:150.05e-6;
        rabiDrive = .05; % amplitdue for drive
        softwareAverages = 500;
        % these are auto calculated
        qubit; % qubit pulse object
        measurement; % measurement pulse object
        qubitStartTimes; % calculated times for when qubit rabi dravie should start
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=RabiDecay(pulseCal)
            obj.pulseCal = pulseCal;
            % constructor generates the necessary objects and calculates the dependent parameters
            % generate qubit object
            obj.qubit = pulselib.measPulse(obj.durationList(1),obj.rabiDrive);
            % generate measurement pulse
            obj.measurement=pulselib.measPulse(obj.pulseCal.measDuration,obj.pulseCal.cavityAmplitude);
            obj.measStartTime = obj.pulseCal.startBuffer + max(obj.durationList) + obj.pulseCal.measBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.pulseCal.endBuffer;
            % calculate qubit pulse times based on the measurement time and
            % the desired delays
            for ind = 1:length(obj.durationList)
                obj.qubitStartTimes(ind)=obj.measStartTime - obj.pulseCal.measBuffer - obj.durationList(ind);
            end
        end
        
        function playlist = directDownloadM8195A(obj,awg)
            display(' ')
            display(['Generating waveforms for ' obj.experimentName])

            % clear awg of segments
            iqseq('delete', [], 'keepOpen', 1);
            % check # segments won't be too large
            if length(obj.durationList)>awg.maxSegNumber
                error(['Waveform library size exceeds maximum segment number ',int2str(awg.maxSegNumber)]);
            end

            % set up time axis and make sure it's correct length for awg
            tStep = 1/obj.pulseCal.samplingRate;
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
            loWaveform = sin(2*pi*obj.pulseCal.cavityFreq*t);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            % since measurement pulse never changes
            [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
            iMeasMod=cos(2*pi*obj.pulseCal.cavityFreq*t).*iMeasBaseband;
            clear iMeasBaseband
            qMeasMod=sin(2*pi*obj.pulseCal.cavityFreq*t).*qMeasBaseband;
            clear qMeasBaseband;
            % background is measurement pulse to get contrast
            backgroundWaveform = iMeasMod+qMeasMod;
            
            for ind=1:length(obj.durationList)
                q=obj.qubit;
                q.duration = obj.durationList(ind);
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitStartTimes(ind));
                iQubitMod=cos(2*pi*obj.pulseCal.qubitFreq*t).*iQubitBaseband;
                clear iQubitBaseband
                qQubitMod=sin(2*pi*obj.pulseCal.qubitFreq*t).*qQubitBaseband;
                clear qQubitBaseband;
                ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
                clear iQubitMod qQubitMod
                
                % now directly loading into awg
                dataId = ind*2-1;
                backId = ind*2;
                % load data segment
                if ind==50
                    pause(1)
                end
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
             % integration and averaging settings from pulseCal
            intStart = obj.pulseCal.integrationStartIndex;
            intStop = obj.pulseCal.integrationStopIndex;
            softavg = obj.softwareAverages;
            % auto update some card settings
            cardparams.segments = length(playlist);
            cardparams.delaytime = obj.measStartTime + obj.pulseCal.cardDelayOffset;
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
            for ind=1:softavg
                % "hardware" averaged I,I^2 data
                [tempI,tempI2,tempQ,tempQ2] = card.ReadIandQcomplicated(awg,playlist);
                % software acumulation
                Idata=Idata+tempI;
                Qdata=Qdata+tempQ;
%                 Pdata=Pdata+tempI2+tempQ2;
                Pdata=Idata.^2+Qdata.^2;
                Pint=mean(Pdata(:,intStart:intStop)');
                
                timeString = datestr(datetime);
                if ~mod(ind,10)
                    figure(187);
                    subplot(2,3,[1 2 3]); 
                    plot(obj.durationList,sqrt(Pint));
                    title([obj.experimentName ' ' timeString '; SoftAvg = ' num2str(ind) '/ ' num2str(softavg)]);
                    ylabel('Integrated sqrt(I^2+Q^2)'); xlabel('Rabi Duration');
                    subplot(2,3,4);
                    imagesc(taxis,obj.durationList,Idata/ind);
                    title('I'); ylabel('Rabi Duration'); xlabel('Time (\mus)');
                    subplot(2,3,5); 
                    imagesc(taxis,obj.durationList,Qdata/ind);
                    title('Q'); ylabel('Rabi Duration'); xlabel('Time (\mus)');
                    subplot(2,3,6);
                    imagesc(taxis,obj.durationList,Pdata/ind);
                    title('I^2+Q^2'); ylabel('Rabi Duration'); xlabel('Time (\mus)');
                    drawnow
                end
                
                
            end
            result.Idata=Idata./softavg;
            result.Qdata=Qdata./softavg;
            result.Pdata=Pdata./softavg;
            result.Pint=Pint./softavg;
            display('Experiment Finished')
        end
    end
end
       