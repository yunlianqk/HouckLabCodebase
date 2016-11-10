classdef RabiDecay_v3 < handle
    % Rabi drive with varying amplitude, following by measurement pulse
    % Readout amplitude is normalized by Identity/X180 on qubit
    % JJR 2016, Princeton
    
    properties 
        experimentName;
        % inputs
        pulseCal;
        duration = 50e-6;
        rabiDrive = linspace(0, 1, 2); % amplitude for drive
%         rabiDrive = .1; % amplitude for drive
        rabiFreq = 4e9;
        softwareAverages = 500;
        % Dependent properties auto calculated in the update method
        zeroGate; % qubit pulse (identity) for normalization
        oneGate; % qubit pulse (X180) for normalization
        sequences; % gateSequence objects
        measurement; % measurement pulse object
        measStartTime; 
        measEndTime;
        sequenceEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=RabiDecay_v3(pulseCal,varargin)
            % constructor. Overwrites durationList if it is passed as an input
            % then calls the update function to calculate dependent
            % properties. If these are changed after construction, rerun
            % update method.
            obj.pulseCal = pulseCal;
            nVarargs = length(varargin);
            switch nVarargs
                case 1
                    obj.duration = varargin{1};
                case 2
                    obj.duration = varargin{1};
                    obj.rabiDrive= varargin{2};
                case 3
                    obj.duration = varargin{1};
                    obj.rabiDrive= varargin{2};
                    obj.softwareAverages = varargin{3};
            end
            name = strsplit(class(obj), '.');
            obj.experimentName = name{end};
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
            obj.measStartTime = obj.pulseCal.startBuffer + maxSeqDuration + obj.pulseCal.measBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.totalDuration;
            obj.waveformEndTime = obj.measEndTime+obj.pulseCal.endBuffer;
            % gate sequence end times are all the same. start times can be
            % calculated on the fly
            obj.sequenceEndTime = obj.measStartTime-obj.pulseCal.measBuffer;
        end
        
        function obj=initSequences(obj)
            % generate qubit objects
            obj.zeroGate = obj.pulseCal.Identity();
            obj.oneGate = obj.pulseCal.X180(); 
                        
            obj.sequences = pulselib.gateSequence();
            for ind = 1:length(obj.rabiDrive)
                % put a placeholder delay into the sequences - rabi drive
                % added later
                gateArray = pulselib.measPulse(obj.duration, obj.rabiDrive(ind));
                obj.sequences(ind) = pulselib.gateSequence(gateArray);
            end
            % create 0 and 1 normalization sequences at end
            obj.sequences(ind+1)=pulselib.gateSequence(obj.zeroGate);
            obj.sequences(ind+2)=pulselib.gateSequence(obj.oneGate);
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
            % generate LO and marker waveforms
            loWaveform = sin(2*pi*obj.pulseCal.cavityFreq*t);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            % since measurement pulse never changes
            [iMeasBaseband, qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
            iMeasMod=cos(2*pi*obj.pulseCal.cavityFreq*t).*iMeasBaseband;
            clear iMeasBaseband;
            qMeasMod=sin(2*pi*obj.pulseCal.cavityFreq*t).*qMeasBaseband;
            clear qMeasBaseband;
            % background is measurement pulse to get contrast
            backgroundWaveform = iMeasMod+qMeasMod;
            % Rabi drives use carrier at obj.rabiFreq
            iQubitCarrier = cos(2*pi*obj.rabiFreq*t);
            qQubitCarrier = sin(2*pi*obj.rabiFreq*t);
            for ind=1:length(obj.sequences)-2
                display(['loading sequence ' num2str(ind)])
                s = obj.sequences(ind);
                tStart = obj.sequenceEndTime - s.totalSequenceDuration;
                [iQubitBaseband, qQubitBaseband] = s.uwWaveforms(t, tStart);
                iQubitMod=iQubitCarrier.*iQubitBaseband;
                clear iQubitBaseband;
                qQubitMod=qQubitCarrier.*qQubitBaseband;
                clear qQubitBaseband;
                ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
                clear iQubitMod qQubitMod;
                
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
            
            % Last two sequences use carrier at pulseCal.qubitFreq
            iQubitCarrier = cos(2*pi*obj.pulseCal.qubitFreq*t);
            qQubitCarrier = sin(2*pi*obj.pulseCal.qubitFreq*t);
            for ind = (length(obj.sequences)-1):length(obj.sequences)
                display(['loading sequence ' num2str(ind)])
                s = obj.sequences(ind);
                tStart = obj.sequenceEndTime - s.totalSequenceDuration;
                [iQubitBaseband, qQubitBaseband] = s.uwWaveforms(t, tStart);
                iQubitMod=iQubitCarrier.*iQubitBaseband;
                clear iQubitBaseband;
                qQubitMod=qQubitCarrier.*qQubitBaseband;
                clear qQubitBaseband;
                ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
                clear iQubitMod qQubitMod;
                
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
            timeString = datestr(datetime);
            for ind=1:softavg
                % "hardware" averaged I,I^2 data
                [tempI,~,tempQ,~] = card.ReadIandQcomplicated(awg,playlist);
                % software acumulation
                Idata=Idata+tempI;
                Qdata=Qdata+tempQ;
                % Pdata=Pdata+tempI2+tempQ2; % correlation function version
                Pdata=Idata.^2+Qdata.^2;
                Pint=mean(Pdata(:,intStart:intStop), 2);
                
                % normalize amplitude
                xaxisNorm=obj.rabiDrive; % 
                amp=sqrt(Pint);
                norm0=amp(end-1);
                norm1=amp(end);
                normRange=norm1-norm0;
                AmpNorm=(amp(1:end-2)-norm0)/normRange;
                
                if ~mod(ind,1)
                    figure(801);
%                     subplot(2,3,[1 2 3]); 
                    plot(obj.rabiDrive,AmpNorm);
                    
                    title([obj.experimentName ' ' timeString '; SoftAvg = ' num2str(ind) '/ ' num2str(softavg)]);
                    ylabel('<Z>'); xlabel('Rabi Amplitude');
                    plotlib.hline(0);plotlib.hline(1);
%                     subplot(2,3,4);
%                     imagesc(taxis,[],Idata/ind);
%                     title('I'); ylabel('Rabi Duration'); xlabel('Time (\mus)');
%                     subplot(2,3,5); 
%                     imagesc(taxis,[],Qdata/ind);
%                     title('Q'); ylabel('Rabi Duration'); xlabel('Time (\mus)');
%                     subplot(2,3,6);
%                     imagesc(taxis,[],Pdata/ind);
%                     title('I^2+Q^2'); ylabel('Rabi Duration'); xlabel('Time (\mus)');
                    drawnow
                end
            end
            result.xaxisNorm = xaxisNorm;
            result.AmpNorm=AmpNorm;
            result.amp = amp;
            display('experiment finished')
        end
    end
end
     
        