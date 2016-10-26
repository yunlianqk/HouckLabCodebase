classdef T2Spectroscopy < handle
    % Hahn Echo experiment - pi/2, delay, pi, delay, pi/2.  Should end up
    % in ground state.  Sweep delays and fit for T2Echo. 
    
    properties 
        experimentName = 'T2Spectroscopy';
        % inputs
        pulseCal;
        specVector = linspace(4.5e9,5e9,101);
        % delayList = 2e-6:1.00e-6:102e-6; % total delay from 1st to last pulse
        delay = 10e-6; % total delay from 1st to last pulse
        softwareAverages = 50; 
        % spec specific properties
        spec; % an extra measurement pulse object for the spec tone
        specAmplitude = 1;
        specStartTime = .5e-6; % time after waveform start to begin spec pulse
        specEndBuffer = 100e-9; % end spec tone just before measurement pulse start
        % Dependent properties auto calculated in the update method
        X90; % qubit pulse object
        zeroGate; % qubit pulse (identity) for normalization
        oneGate; % qubit pulse (X180) for normalization
        sequences; % gateSequence objects
        measurement; % measurement pulse object
        measStartTime; 
        measEndTime;
        sequenceEndTime;
        waveformEndTime;
        specEndTime;
        specDuration;
    end
    
    methods
        function obj=T2Spectroscopy(pulseCal,varargin)
            % constructor. Overwrites delayList if it is passed as an input
            % then calls the update function to calculate dependent
            % properties. If these are changed after construction, rerun
            % update method.
            obj.pulseCal = pulseCal;
            nVarargs = length(varargin);
            switch nVarargs
                case 1
                    obj.specVector = varargin{1};
                case 2
                    obj.specVector = varargin{1};
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
            obj.measStartTime = obj.pulseCal.startBuffer + maxSeqDuration + obj.pulseCal.measBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.totalDuration;
            obj.waveformEndTime = obj.measEndTime+obj.pulseCal.endBuffer;
            % gate sequence end times are all the same. start times can be
            % calculated on the fly
            obj.sequenceEndTime = obj.measStartTime-obj.pulseCal.measBuffer;
            
            % create spec tone
            obj.specEndTime = obj.measStartTime - obj.specEndBuffer;
            obj.specDuration = obj.specEndTime - obj.specStartTime;
            obj.spec = pulselib.measPulse(obj.specDuration,obj.specAmplitude);
        end
        
        function obj=initSequences(obj)
            % generate qubit objects
            obj.X90 = obj.pulseCal.X90();
            obj.zeroGate = obj.pulseCal.Identity();
            obj.oneGate = obj.pulseCal.X180(); 
                        
            sequences(1,length(obj.specVector)) = pulselib.gateSequence(); % initialize empty array of gateSequence objects
            for ind = 1:length(obj.specVector)
                delayGateTime = obj.delay - obj.X90.totalDuration; % so that pulse delays match the delayList
                delayGate = obj.pulseCal.Delay(delayGateTime);
                gateArray = [obj.X90 delayGate obj.X90];
                sequences(ind)=pulselib.gateSequence(gateArray);
            end
            % create 0 and 1 normalization sequences at end
            sequences(ind+1)=pulselib.gateSequence(obj.zeroGate);
            sequences(ind+2)=pulselib.gateSequence(obj.oneGate);
            obj.sequences=sequences;
        end
        
        function playlist = directDownloadM8195A(obj,awg)
            display(['Generating waveforms for ' obj.experimentName])
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
            [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
            iMeasMod=cos(2*pi*obj.pulseCal.cavityFreq*t).*iMeasBaseband;
            clear iMeasBaseband
            qMeasMod=sin(2*pi*obj.pulseCal.cavityFreq*t).*qMeasBaseband;
            clear qMeasBaseband;
            % background is measurement pulse to get contrast
            backgroundWaveform = iMeasMod+qMeasMod;
            % for T2Spec measurement the qubit pulses never change
            s = obj.sequences(1);
            tStart = obj.sequenceEndTime - s.totalSequenceDuration;
            [iQubitMod, qQubitMod] = s.modWaveforms(t, tStart, obj.pulseCal.qubitFreq);
            qubitPlusMeas = iQubitMod + qQubitMod + iMeasMod + qMeasMod;
            clear iMeasMod qMeasMod iQubitMod qQubitMod
            for ind=1:length(obj.sequences)
                display(['loading sequence ' num2str(ind)])
                % avoid putting in spec pulse for normalization sequences
                % at end.
                if ind < length(obj.sequences)-1
                    % generate spec pulse
                    specFreq = obj.specVector(ind);
                    [iSpecBaseband qSpecBaseband] = obj.spec.uwWaveforms(t,obj.specStartTime);
                    iSpecMod=cos(2*pi*specFreq*t).*iSpecBaseband;
                    clear iSpecBaseband
                    qSpecMod=sin(2*pi*specFreq*t).*qSpecBaseband;
                    clear qSpecBaseband;
                    ch1waveform = qubitPlusMeas + iSpecMod + qSpecMod;
                    clear iSpecMod qSpecMod
                else
                    ch1waveform = qubitPlusMeas;
                end
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
%                 clear backgroundWaveform;
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
            display(['Running ' obj.experimentName])
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
                % phaseData = phaseData + atan(tempQ./tempI);
                % phaseInt = mean(phaseData(:,intStart:intStop)');
                
                % normalize amplitude
                xaxisNorm=obj.specVector; % 
                amp=sqrt(Pint);
                norm0=amp(end-1);
                norm1=amp(end);
                normRange=norm1-norm0;
                AmpNorm=(amp(1:end-2)-norm0)/normRange;
                
                timeString = datestr(datetime);
                if ~mod(ind,10)
                    figure(187);
                    subplot(2,3,[1 2 3]); 
                    plot(xaxisNorm,AmpNorm);
                    % fitResults = funclib.ExpFit2(xaxisNorm,AmpNorm);
                    % title([obj.experimentName ' ' timeString '; ' num2str(obj.echoOrder) ' Pi pulses; T2Echo = ' num2str(fitResults.lambda) ' SoftAvg = ' num2str(ind) '/ ' num2str(softavg)]);
                    ylabel('Normalized Amplitude'); xlabel('Spec Freq');
                    subplot(2,3,4);
                    imagesc(taxis,[],Idata/ind);
                    title('I'); ylabel('segments'); xlabel('Time (\mus)');
                    subplot(2,3,5); 
                    imagesc(taxis,[],Qdata/ind);
                    title('Q'); ylabel('segments'); xlabel('Time (\mus)');
                    subplot(2,3,6);
                    imagesc(taxis,[],Pdata/ind);
                    title('I^2+Q^2'); ylabel('segments'); xlabel('Time (\mus)');
                    drawnow
                end
            end
            figure(187);
            subplot(2,3,[1 2 3]);
            plot(xaxisNorm,AmpNorm);
            % fitResults = funclib.ExpFit2(xaxisNorm,AmpNorm);
            % title([obj.experimentName ' ' timeString '; ' num2str(obj.echoOrder) ' Pi pulses; T2Echo = ' num2str(fitResults.lambda) ' SoftAvg = ' num2str(ind) '/ ' num2str(softavg)]);
            ylabel('Normalized Amplitude'); xlabel('Spec Freq');
            result.taxis = taxis;
            result.xaxisNorm = xaxisNorm;
            result.Idata=Idata./softavg;
            result.Qdata=Qdata./softavg;
            result.Pdata=Pdata./softavg;
            result.Pint=Pint./softavg;
            result.AmpNorm=AmpNorm;
%             result.fitResults = fitResults;
            display('Experiment Finished')
        end
    end
end
       
        
        
        