classdef SingleShotHistograms < handle
    % alternate between trials in the ground state and trials in the
    % excited. Keep single shot data and histogram them.
    
    properties 
        experimentName = 'SingleShotHistograms';
        % inputs
        pulseCal;
        softwareRepeats = 100; % to collect more trials
        % Dependent properties auto calculated in the update method
        qubit; % qubit pulse object
        measurement; % measurement pulse object
        qubitPulseTime;
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=SingleShotHistograms(pulseCal,varargin)
            % constructor. Overwrites ampVector if it is passed as an input
            % then calls the update function to calculate dependent
            % properties. If these are changed after construction, rerun
            % update method.
            obj.pulseCal = pulseCal;
%             nVarargs = length(varargin);
%             switch nVarargs
%                 case 1
%                     obj.softwareRepeats = varargin{1};
%                 case 2
%                     obj.ampVector = varargin{1};
%                     obj.softwareAverages = varargin{2};
%             end
            obj.update();
        end
    
        function obj=update(obj)
            % run this to update dependent parameters after changing
            % experiment details
            obj.qubit = obj.pulseCal.X180();
%             obj.qubit = obj.pulseCal.Identity();
            obj.measurement = obj.pulseCal.measurement();
            obj.qubitPulseTime = obj.pulseCal.startBuffer+obj.qubit.totalDuration/2;
            obj.measStartTime = obj.qubitPulseTime + obj.qubit.totalDuration/2 + obj.pulseCal.measBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.pulseCal.endBuffer;
        end
        
        function playlist = directDownloadM8195A(obj,awg)
            display(' ')
            display(['Generating waveforms for ' obj.experimentName])

            % clear awg of segments
            iqseq('delete', [], 'keepOpen', 1);
            % check # segments won't be too large
            if length(2)>awg.maxSegNumber
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
            
            % generate first segment - excited state
            q = obj.qubit;
            [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTime);
            iQubitMod=cos(2*pi*obj.pulseCal.qubitFreq*t).*iQubitBaseband;
            clear iQubitBaseband;
            qQubitMod=sin(2*pi*obj.pulseCal.qubitFreq*t).*qQubitBaseband;
            clear qQubitBaseband;
            [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
            iMeasMod=cos(2*pi*obj.pulseCal.cavityFreq*t).*iMeasBaseband;
            clear iMeasBaseband
            qMeasMod=sin(2*pi*obj.pulseCal.cavityFreq*t).*qMeasBaseband;
            clear qMeasBaseband;
            ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
            clear iQubitMod qQubitMod
            % background is measurement pulse to get contrast
            backgroundWaveform = iMeasMod+qMeasMod;
            %                 backgroundWaveform = real(iqcorrection(backgroundWaveform,awg.samplerate));
            clear iMeasMod qMeasMod
            
            % now directly loading into awg
            dataId = 1;
            backId = 2;
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
            % last playlist item must have advance set to 'auto'
            playlist(backId).segmentAdvance = 'Auto';
        end
        
         function [result] = directRunM8195A(obj,awg,card,cardparams,playlist)
            display(' ')
            display(['Running ' obj.experimentName])
            % integration and averaging settings from pulseCal
%             intStart = obj.pulseCal.integrationStartIndex;
%             intStop = obj.pulseCal.integrationStopIndex;
%             softavg = obj.softwareAverages;
            % auto update some card settings
            cardparams.segments = length(playlist);
            cardparams.delaytime = obj.measStartTime + obj.pulseCal.cardDelayOffset;
            card.SetParams(cardparams);
%             tstep=1/card.params.samplerate;
%             taxis=(tstep:tstep:card.params.samples/card.params.samplerate)'./1e-6;%mus units
            
            % READ
            % intialize matrices
            ex = zeros(obj.softwareRepeats,cardparams.averages);
            gnd = zeros(obj.softwareRepeats,cardparams.averages);
            for ind = 1:obj.softwareRepeats
                [Idata, Qdata] = card.ReadIandQsingleShot(awg,playlist);
                Isum = sum(Idata);
                Isum = sum(Qdata);
                Adata = sqrt(Idata.^2+Qdata.^2);
                Aint = sum(Adata);
                ex(ind,:) = Aint(1,1:2:end);
                gnd(ind,:) = Aint(1,2:2:end);
                
                figure(111);
                h1 = histogram(ex(1:ind,:))
                hold on
                h2 = histogram(gnd(1:ind,:))
                h2.BinWidth = h1.BinWidth;
                h1.Normalization = 'probability';
                h2.Normalization = 'probability';
                hold off
                drawnow
            end
                
%             
%             %             for ind=1:softavg
%                 % "hardware" averaged I,I^2 data
%             
%                 clear tempI2 tempQ2 % these aren't being used right now...
%                 % software acumulation
%                 Idata=Idata+tempI;
%                 Qdata=Qdata+tempQ;
%                 % Pdata=Pdata+tempI2+tempQ2; % correlation function version
%                 Pdata=Idata.^2+Qdata.^2;
%                 Pint=mean(Pdata(:,intStart:intStop)');
%                 % phaseData = phaseData + atan(tempQ./tempI);
%                 % phaseInt = mean(phaseData(:,intStart:intStop)');
% 
%                 timeString = datestr(datetime);
%                 if ~mod(ind,10)
%                     figure(187);
%                     subplot(2,3,[1 2 3]); 
%                     newAmp=funclib.RabiFit2(obj.ampVector,sqrt(Pint));
%                     % plot(obj.ampVector,sqrt(Pint));
%                     title([obj.experimentName ' ' timeString ' newAmp = ' num2str(newAmp) '; SoftAvg = ' num2str(ind) '/ ' num2str(softavg)]);
%                     ylabel('Integrated sqrt(I^2+Q^2)'); xlabel('Pulse Amplitude');
%                     subplot(2,3,4);
%                     imagesc(taxis,obj.ampVector,Idata/ind);
%                     title('I'); ylabel('Pulse Amplitude'); xlabel('Time (\mus)');
%                     subplot(2,3,5); 
%                     imagesc(taxis,obj.ampVector,Qdata/ind);
%                     title('Q'); ylabel('Pulse Amplitude'); xlabel('Time (\mus)');
%                     subplot(2,3,6);
%                     imagesc(taxis,obj.ampVector,Pdata/ind);
%                     title('I^2+Q^2'); ylabel('Pulse Amplitude'); xlabel('Time (\mus)');
%                     drawnow
%                 end
%             end
%             figure(187);
%             subplot(2,3,[1 2 3]);
%             newAmp=funclib.RabiFit2(obj.ampVector,sqrt(Pint));
%             title([obj.experimentName ' ' timeString ' newAmp = ' num2str(newAmp) '; SoftAvg = ' num2str(ind) '/ ' num2str(softavg)]);
%             ylabel('Integrated sqrt(I^2+Q^2)'); xlabel('Pulse Amplitude');
%             
%             result.taxis = taxis;
%             result.Idata=Idata./softavg;
%             result.Qdata=Qdata./softavg;
%             result.Pdata=Pdata./softavg;
%             result.Pint=Pint./softavg;
%             result.newAmp=newAmp;
            result.ex = ex;
            result.gnd = gnd;
            display('Experiment Finished')
         end
    end
end
        
        
        
        