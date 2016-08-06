classdef T2Experiment < handle
    % Simple T2 Experiment. Two pi/2 X pulses with varying delay. JJR 2016, Princeton
    % This experiment just uses an X pi pulse at half power for the pi/2
    % pulses, NOT a separately optimized pi/2 pulse1
    
    properties
        % change these to tweak the experiment
%         qubitFreq=4.772869998748302e9;
        qubitFreq=4.772869998748302e9-2e6;
        qubitAmplitude = .74/2;
        qubitSigma = 25e-9;
        gateType = 'X90';
        delayList = 200e-9:.05e-6:20.2e-6; % delay btw qubit pulses
        interPulseBuffer = 200e-9; % time between final qubit pulse and measurement pulse
        cavityFreq=10.16578e9; % cavity frequency
        cavityAmp=1;       % cavity pulse amplitude
        measDuration = 5e-6;
        startBuffer = 5e-6; % buffer at beginning of waveform
        endBuffer = 5e-6; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        qubit1; % qubit pulse object
        qubit2; % qubit pulse object
        measurement; % measurement pulse object
        qubit1PulseTimes; % calculated times for when 1st pulses should occur (tCenter)
        qubit2PulseTime; % calculated time for 2nd pulse(tCenter)
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=T2Experiment()
            % constructor generates the necessary objects and calculates the dependent parameters
            % generate qubit objects
            obj.qubit1 = pulselib.singleGate(obj.gateType);
            obj.qubit1.amplitude = obj.qubitAmplitude;
            obj.qubit1.sigma = obj.qubitSigma;
            obj.qubit1.cutoff = 4*obj.qubitSigma;
            obj.qubit2 = pulselib.singleGate(obj.gateType);
            obj.qubit2.amplitude = obj.qubitAmplitude;
            obj.qubit2.sigma = obj.qubitSigma;
            obj.qubit2.cutoff = 4*obj.qubitSigma;
            % generate measurement pulse
            obj.measurement=pulselib.measPulse(obj.measDuration,obj.cavityAmp);
            % calculate measurement pulse times - based on the max
            % delay btw 1st qubit pulse and measurement
            obj.measStartTime = obj.startBuffer + max(obj.delayList) + obj.interPulseBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
            % calculate qubit pulse times based on the measurement time and
            % the desired delays
            obj.qubit2PulseTime = obj.measStartTime - obj.interPulseBuffer;
            for ind = 1:length(obj.delayList)
                obj.qubit1PulseTimes(ind)=obj.qubit2PulseTime-obj.delayList(ind);
            end
        end
        
%         function w = genWaveset_M8195A(obj)
%             w = paramlib.M8195A.waveset();
%             tStep = 1/obj.samplingRate;
%             t = 0:tStep:(obj.waveformEndTime);
%             ch2waveform = sin(2*pi*obj.cavityFreq*t); % lo waveform is always the same
%             for ind=1:length(obj.delayList)
%                 q1=obj.qubit1;
%                 q2=obj.qubit2;
%                 [iQubit1Baseband qQubit1Baseband] = q1.uwWaveforms(t, obj.qubit1PulseTimes(ind));
%                 [iQubit2Baseband qQubit2Baseband] = q2.uwWaveforms(t, obj.qubit2PulseTime);
%                 iQB=iQubit1Baseband+iQubit2Baseband;
%                 qQB=qQubit1Baseband+qQubit2Baseband;
%                 iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQB;
%                 qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQB;
%                 [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
%                 iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
%                 qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
%                 ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
%                 s1=w.newSegment(ch1waveform);
%                 p1=w.newPlaylistItem(s1);
%                 % since s2 will be played simultaneously with s1, it does
%                 % not need its own playlist item!
%                 slo=w.newSegment(ch2waveform,[0 0; 1 0; 0 0; 0 0]);
%                 % set lo to play simultaneously
%                 slo.id = s1.id;
%             end
%             % last playlist item must have advance set to 'auto'
%             p1.advance='Auto';
%         end
%         
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
                q1=obj.qubit1;
                q2=obj.qubit2;
                [iQubit1Baseband qQubit1Baseband] = q1.uwWaveforms(t, obj.qubit1PulseTimes(ind));
                [iQubit2Baseband qQubit2Baseband] = q2.uwWaveforms(t, obj.qubit2PulseTime);
                iQB=iQubit1Baseband+iQubit2Baseband;
                clear iQubit1Baseband iQubit2Baseband;
                qQB=qQubit1Baseband+qQubit2Baseband;
                clear qQubit1Baseband qQubit2Baseband;
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQB;
                clear iQB;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQB;
                clear qQB;
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
            softavg=200; % software averages
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
            T2Data=zeros(cardparams.segments/2);
            for ind=1:softavg
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
                
                if ~mod(ind,10)
                    figure(101);
                    subplot(2,3,1); imagesc(taxis,obj.delayList,Idata/ind);title(['In phase. N=' num2str(ind)]);ylabel('Delay');xlabel('Time (\mus)');
                    subplot(2,3,2); imagesc(taxis,obj.delayList,Qdata/ind);title('Quad phase');ylabel('Delay');xlabel('Time (\mus)');
                    subplot(2,3,4); imagesc(taxis,obj.delayList,Pdata/ind);title('Power I^2+Q^2');ylabel('Delay');xlabel('Time (\mus)');
                    subplot(2,3,5); imagesc(taxis,obj.delayList./1e9,phaseData/ind);title('Phase atan(Q/I)');ylabel('Delay');xlabel('Time (\mus)');
                    subplot(2,3,3); plot(obj.delayList,sqrt(Pint));ylabel('Power I^2+Q^2');xlabel('Delay');
                    subplot(2,3,6); plot(obj.delayList./1e9,phaseInt);ylabel('Integrated Phase');xlabel('Delay');
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
        
        
        
        
        
        
        
    end
end
       