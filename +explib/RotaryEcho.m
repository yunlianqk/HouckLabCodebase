classdef RotaryEcho < handle
    % T1 Experiment. X pulse with varying delay. JJR 2016, Princeton
    
    properties 
        experimentName = 'RotaryEcho';
        % inputs
        pulseCal;
%         durationList = 50e-9:.30e-6:100.05e-6;
%         durationList = 50e-9:500e-9:100e-6;
%         durationList = logspace(log10(50e-9),log10(250e-6),50); % total delay from 1st to last pulse
        durationList = logspace(log10(1.5e-6),log10(250e-6),32); % total delay from 1st to last pulse
        rabiDrive = .1; % amplitude for drive
        softwareAverages = 10; 
        % Dependent properties auto calculated in the update method
        qubit; % main pulse
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
        function obj=RotaryEcho(pulseCal,varargin)
            % constructor. Overwrites durationList if it is passed as an input
            % then calls the update function to calculate dependent
            % properties. If these are changed after construction, rerun
            % update method.
            obj.pulseCal = pulseCal;
            nVarargs = length(varargin);
            switch nVarargs
                case 1
                    obj.durationList = varargin{1};
                case 2
                    obj.durationList = varargin{1};
                    obj.rabiDrive= varargin{2};
                case 3
                    obj.durationList = varargin{1};
                    obj.rabiDrive= varargin{2};
                    obj.softwareAverages = varargin{3};
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
        end
        
        function obj=initSequences(obj)
            % generate qubit objects
            obj.qubit = pulselib.measPulse(obj.durationList(1)/2,obj.rabiDrive);
            obj.zeroGate = obj.pulseCal.Identity();
            obj.oneGate = obj.pulseCal.X180(); 
                        
            sequences(1,length(obj.durationList)+2) = pulselib.gateSequence(); % initialize empty array of gateSequence objects
            for ind = 1:length(obj.durationList)
                % put a placeholder delay into the sequences - rabi drive
                % added later
                delayGateTime = obj.durationList(ind);
                delayGate = obj.pulseCal.Delay(delayGateTime);
                gateArray = [delayGate];
                sequences(ind)=pulselib.gateSequence(gateArray);
            end
            % create 0 and 1 normalization sequences at end
            sequences(ind+1)=pulselib.gateSequence(obj.zeroGate);
            sequences(ind+2)=pulselib.gateSequence(obj.oneGate);
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
            % generate LO and marker waveforms
            loWaveform = sin(2*pi*obj.pulseCal.cavityFreq*t);
            iQubitCarrier = cos(2*pi*obj.pulseCal.qubitFreq*t);
            qQubitCarrier = sin(2*pi*obj.pulseCal.qubitFreq*t);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            % since measurement pulse never changes
            [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
            iMeasMod=cos(2*pi*obj.pulseCal.cavityFreq*t).*iMeasBaseband;
            clear iMeasBaseband
            qMeasMod=sin(2*pi*obj.pulseCal.cavityFreq*t).*qMeasBaseband;
            clear qMeasBaseband;
            % background is measurement pulse to get contrast
            backgroundWaveform = iMeasMod+qMeasMod;
            
            for ind=1:length(obj.sequences)
                display(['loading sequence ' num2str(ind)])
                s = obj.sequences(ind);
                tStart = obj.sequenceEndTime - s.totalSequenceDuration;
                [iQubitBaseband qQubitBaseband] = s.uwWaveforms(t, tStart);
                % goofy hack to add in rabi drive because it's not a
                % singlepulse object...
                if ind <= length(obj.durationList)
                    q = obj.qubit;
                    q.duration = obj.durationList(ind)/2;
                    [iRabi1 qRabi1] = q.uwWaveforms(t, tStart);
                    tStart2 = tStart + q.totalDuration;
                    q.amplitude = -q.amplitude;
                    [iRabi2 qRabi2] = q.uwWaveforms(t, tStart2);
                    q.amplitude = -q.amplitude;
                    iRabi = iRabi1 + iRabi2;
                    qRabi = qRabi1 + qRabi2;
                    iQubitBaseband = iQubitBaseband + iRabi;
                    qQubitBaseband = qQubitBaseband + qRabi;
                    
                end
                    
                iQubitMod=iQubitCarrier.*iQubitBaseband;
%                 clear iQubitBaseband;
                qQubitMod=qQubitCarrier.*qQubitBaseband;
%                 clear qQubitBaseband;
                ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
                clear iQubitMod qQubitMod
                
%                 startind = find(t>tStart,1);
%                 stopind = find(t>obj.measEndTime,1);
%                 figure(111);
%                 plot(t(startind:stopind),iQubitBaseband(startind:stopind),'b',t(startind:stopind),iMeasMod(startind:stopind));
%                 drawnow

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
            timeString = datestr(datetime);
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
                
                % normalize amplitude
                xaxisNorm=obj.durationList; % 
                amp=sqrt(Pint);
                norm0=amp(end-1);
                norm1=amp(end);
                normRange=norm1-norm0;
                AmpNorm=(amp(1:end-2)-norm0)/normRange;
                
                if ~mod(ind,1)
                    figure(321);
                    plot(xaxisNorm,AmpNorm)
                    %                     ax = gca;
%                     fitResults = funclib.ExpFit3(xaxisNorm,AmpNorm,ax);
%                     title(ax,[' Rotary Echo: ' num2str(fitResults.lambda) '; N=' num2str(ind)])
                    title([' Rotary Echo:; N=' num2str(ind)])
                    ylabel('Normalized Amplitude'); xlabel('Delay');
                    drawnow
                end
                
%                 if ~mod(ind,1)
%                     figure(801);
%                     subplot(2,3,[1 2 3]); 
%                     plot(obj.durationList,AmpNorm);
                    
%                     title([obj.experimentName ' ' timeString '; SoftAvg = ' num2str(ind) '/ ' num2str(softavg)]);
%                     ylabel('<Z>'); xlabel('Total Duration of both drives');
%                     plotlib.hline(0);plotlib.hline(1);
%                     subplot(2,3,4);
%                     imagesc(taxis,[],Idata/ind);
%                     title('I'); ylabel('Rabi Duration'); xlabel('Time (\mus)');
%                     subplot(2,3,5); 
%                     imagesc(taxis,[],Qdata/ind);
%                     title('Q'); ylabel('Rabi Duration'); xlabel('Time (\mus)');
%                     subplot(2,3,6);
%                     imagesc(taxis,[],Pdata/ind);
%                     title('I^2+Q^2'); ylabel('Rabi Duration'); xlabel('Time (\mus)');
%                     drawnow
%                 end
            end
            result.xaxisNorm = xaxisNorm;
            result.AmpNorm=AmpNorm;
            result.amp = amp;
%             result.fitResults = fitResults;
            display('experiment finished')
        end
    end
end
     
        