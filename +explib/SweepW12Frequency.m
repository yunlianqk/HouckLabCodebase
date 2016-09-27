classdef SweepW12Frequency < handle
% pi pulse followed by 2nd pulse to drive to 2nd excited state. sweep 2nd
% pulse to locate w12
    
    properties 
        experimentName = 'SweepW12Frequency';
        % inputs
        pulseCal;
%         freqVector = linspace(4.5e9,4.76e9,101);
        freqVector = linspace(4.3e9,4.5e9,201);
%         freqVector = linspace(1e-6,4.5e9,201);
        softwareAverages = 100; 
        % Dependent properties auto calculated in the update method
        qubit; % main pulse
        w12pulse; % 2nd pulse to drive to 2nd excited state
        sequences; % gateSequence objects
        measurement; % measurement pulse object
        measStartTime; 
        measEndTime;
        sequenceEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=SweepW12Frequency(pulseCal,varargin)
            % constructor. Overwrites delayList if it is passed as an input
            % then calls the update function to calculate dependent
            % properties. If these are changed after construction, rerun
            % update method.
            obj.pulseCal = pulseCal;
            nVarargs = length(varargin);
            switch nVarargs
                case 1
                    obj.freqVector = varargin{1};
                case 2
                    obj.freqVector = varargin{1};
                    obj.softwareAverages = varargin{2};
            end
            obj.update();
        end
        
        function obj=update(obj)
            % run this to update dependent parameters after changing
            % experiment details
            obj.initSequences(); % init routine to build gate sequences
            
            % generate measurement pulse
            obj.measurement = obj.pulseCal.measurement();
            
            % calculate measurement pulse time - based on the max number of
            % gates
            seqDurations = [obj.sequences.totalSequenceDuration];
            maxSeqDuration = max(seqDurations);
            % add time for an extra pulse after sequence ends
            obj.measStartTime = obj.pulseCal.startBuffer + maxSeqDuration + obj.w12pulse.totalDuration + obj.pulseCal.measBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.totalDuration;
            obj.waveformEndTime = obj.measEndTime+obj.pulseCal.endBuffer;
            % gate sequence end times are all the same. start times can be
            % calculated on the fly
            obj.sequenceEndTime = obj.measStartTime-obj.pulseCal.measBuffer;
        end
        
        function obj=initSequences(obj)
            % generate qubit objects
            obj.qubit = obj.pulseCal.X180();
            obj.w12pulse = obj.pulseCal.X180();
            obj.w12pulse.sigma=50e-9;
            obj.w12pulse.cutoff=4*obj.w12pulse.sigma;
%             obj.zeroGate = obj.pulseCal.Identity();
%             obj.oneGate = obj.pulseCal.X180(); 
                        
            sequences(1,length(obj.freqVector)) = pulselib.gateSequence(); % initialize empty array of gateSequence objects
            for ind = 1:length(obj.freqVector)
                gateArray = [obj.qubit];
                sequences(ind)=pulselib.gateSequence(gateArray);
            end
            % create 0 and 1 normalization sequences at end
%             sequences(ind+1)=pulselib.gateSequence(obj.zeroGate);
%             sequences(ind+2)=pulselib.gateSequence(obj.oneGate);
            obj.sequences=sequences;
        end
        
        function playlist = directDownloadM8195A(obj,awg)
            % avoid building full wavesets and WaveLib to save memory 

            % clear awg of segments
            iqseq('delete', [], 'keepOpen', 1);
            % check # segments won't be too large
            if length(obj.sequences)>awg.maxSegNumber
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
            % generate marker waveforms
            
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            
            for ind=1:length(obj.sequences)
                display(['loading sequence ' num2str(ind)])
                s = obj.sequences(ind);
                tStart = obj.sequenceEndTime - s.totalSequenceDuration;
                [iQubitBaseband qQubitBaseband] = s.uwWaveforms(t, tStart);
                iQubitMod=cos(2*pi*obj.pulseCal.qubitFreq*t).*iQubitBaseband;
                clear iQubitBaseband;
                qQubitMod=sin(2*pi*obj.pulseCal.qubitFreq*t).*qQubitBaseband;
                clear qQubitBaseband;
                % add 2nd qubit pulse
                w12 = obj.w12pulse;
                w12centerTime = obj.sequenceEndTime+w12.totalDuration/2;
                [iW12Baseband qW12Baseband] = w12.uwWaveforms(t, w12centerTime);
                iW12Mod=cos(2*pi*obj.freqVector(ind)*t).*iW12Baseband;
                clear iW12Baseband;
                qW12Mod=sin(2*pi*obj.freqVector(ind)*t).*qW12Baseband;
                clear qW12Baseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.pulseCal.cavityFreq*t).*iMeasBaseband;
                clear iMeasBaseband
                qMeasMod=sin(2*pi*obj.pulseCal.cavityFreq*t).*qMeasBaseband;
                clear qMeasBaseband;
                ch1waveform = iQubitMod+qQubitMod+iW12Mod+qW12Mod+iMeasMod+qMeasMod;
%                 ch1waveform = iMeasMod+qMeasMod;
%                 clear iQubitMod qQubitMod
                loWaveform = sin(2*pi*obj.pulseCal.cavityFreq*t);
                backgroundWaveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;

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
            for ind=1:softavg
                % "hardware" averaged I,I^2 data
                [tempI,tempI2,tempQ,tempQ2] = card.ReadIandQcomplicated(awg,playlist);
                clear tempI2 tempQ2 % these aren't being used right now...
                % software acumulation
                Idata=Idata+tempI;
                Qdata=Qdata+tempQ;
                % Pdata=Pdata+tempI2+tempQ2; % correlation function version
                Pdata=Idata.^2+Qdata.^2;
                Pint=mean(Pdata(:,intStart:intStop)');
                
%                 % normalize amplitude
%                 xaxisNorm=obj.delayList; % 
%                 amp=sqrt(Pint);
%                 norm0=amp(end-1);
%                 norm1=amp(end);
%                 normRange=norm1-norm0;
%                 AmpNorm=(amp(1:end-2)-norm0)/normRange;
                
                timeString = datestr(datetime);
                if ~mod(ind,1)
                    figure(101);
                    plot(obj.freqVector,Pint);
%                     ax = gca;
%                     fitResults = funclib.ExpFit3(xaxisNorm,AmpNorm,ax);
%                     title(ax,[' T1: ' num2str(fitResults.lambda) '; N=' num2str(ind)])
%                     ylabel('Normalized Amplitude'); xlabel('Delay');
                    drawnow
                end
            end
            result.freqVector = obj.freqVector;
            result.Pint = Pint;
        end
    end
end
     
        