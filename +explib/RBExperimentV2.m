classdef RBExperimentV2 < handle
    % Randomized Benchmarking Experiment object for generating waveforms to
    % be sent to the awg. JJR 2016, Princeton
    
    properties
        experimentName = 'RandomizedBenchmarkV2';
        % inputs
        pulseCal;
%         sequenceLengths = [2 3 4 5 6 8 10 12 16 20 24 32 40 48 64 80 96]; % This is from Jerry's thesis pg 155
        sequenceLengths = floor(2*(linspace(1,21,32)).^2);
        softwareAverages = 50;
        % these are auto calculated
        primitives; % object array of primitive gates.
        iPrimitiveWaveforms; % baseband waveforms never change, so only calculate them once.
        qPrimitiveWaveforms; % baseband waveforms never change, so only calculate them once.
        cliffords; % object array of clifford gates.
        sequences; % object array of randomized benchmarking sequences
        measurement; % measurement pulse object
        rbEndTime;
        measStartTime; % starts shortly after end of the rbSequence 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=RBExperimentV2(pulseCal, varargin)% constructor
            % constructor. Overwrites sequenceLengths if it is passed as an input
            % then calls the update function to calculate dependent
            % properties. If these are changed after construction, rerun
            % update method.
            obj.pulseCal = pulseCal;
            nVarargs = length(varargin);
            switch nVarargs
                case 1
                    obj.numGateVector = varargin{1};
                case 2
                    obj.numGateVector = varargin{1};
                    obj.softwareAverages = varargin{2};
            end
            obj.update();
        end
            
        function obj=update(obj)
            % run this to update dependent parameters after changing
            % experiment details
            obj.initPrimitives();
            obj.initCliffords();
            obj.measurement = obj.pulseCal.measurement();
            obj.initSequences();
        end
        
        function obj=set.sequenceLengths(obj,s)
            obj.sequenceLengths=s;
            obj.update();
        end
        
        function obj=initPrimitives(obj)
            primitives(1) = obj.pulseCal.Identity();
            primitives(2) = obj.pulseCal.X180();
            primitives(3) = obj.pulseCal.X90();
            primitives(4) = obj.pulseCal.Xm90();
            primitives(5) = obj.pulseCal.Y180();
            primitives(6) = obj.pulseCal.Y90();
            primitives(7) = obj.pulseCal.Ym90();
            obj.primitives=primitives;
            
            for ind=1:length(primitives)
                tAxis = 0 : 1/obj.pulseCal.samplingRate : primitives(ind).totalDuration;
                tCenter = primitives(ind).totalDuration / 2;
                [iTemp qTemp] = primitives(ind).uwWaveformsSlow(tAxis,tCenter);
                iPrimitiveWaveforms(:,ind) = iTemp;
                qPrimitiveWaveforms(:,ind) = qTemp;
            end
            obj.iPrimitiveWaveforms = iPrimitiveWaveforms;
            obj.qPrimitiveWaveforms = qPrimitiveWaveforms;
        end
        
        function obj=initCliffords(obj) % generate object array of cliffords
            % call crazy code to randomly generate the decomposition of
            % cliffords into primitives.
            [cliffs,Clfrdstring]=explib.RB.SingleQubitCliffords();
            for ind1=1:length(cliffs)
                unitary=cliffs{ind1};
                primStrings=Clfrdstring{ind1};
                
                % traverse list of primitive names and find index for gate
                % object array
                primDecompInd = [];
                primDecomp = [];
                for ind2=1:length(primStrings)
                    if(strcmp(primStrings{ind2},'X90pPulse')==1)
                        primDecompInd = [primDecompInd 3];
                        primDecomp = [primDecomp obj.primitives(3)];
                    elseif(strcmp(primStrings{ind2},'X90mPulse')==1)
                        primDecompInd = [primDecompInd 4];
                        primDecomp = [primDecomp obj.primitives(4)];
                    elseif(strcmp(primStrings{ind2},'Y90pPulse')==1)
                        primDecompInd = [primDecompInd 6];
                        primDecomp = [primDecomp obj.primitives(6)];
                    elseif(strcmp(primStrings{ind2},'Y90mPulse')==1)
                        primDecompInd = [primDecompInd 7];
                        primDecomp = [primDecomp obj.primitives(7)];
                    elseif(strcmp(primStrings{ind2},'XpPulse')==1)
                        primDecompInd = [primDecompInd 2];
                        primDecomp = [primDecomp obj.primitives(2)];
                    elseif(strcmp(primStrings{ind2},'YpPulse')==1)
                        primDecompInd = [primDecompInd 5];
                        primDecomp = [primDecomp obj.primitives(5)];
                    elseif(strcmp(primStrings{ind2},'QIdPulse')==1)
                        primDecompInd = [primDecompInd 1];
                        primDecomp = [primDecomp obj.primitives(1)];
                    end
                end
                cliffords(ind1)=explib.RB.cliffordGate(ind1,unitary,primDecomp);
            end
            obj.cliffords=cliffords;
        end
        
        function obj=initSequences(obj)
            % using sequenceLengths, generate the sequence objects
            s = obj.sequenceLengths;
            [m, mInd]=max(s);
            numCliffords=length(obj.cliffords);
            
            % generate random sequence of cliffords with max sequenceLength
            rng('default');
            rng('shuffle');
            maxSequence = randi(numCliffords, [1,m]);
            
            % for each sequence length create a sequence object
            for ind=1:length(s)
                seqList=maxSequence(1:s(ind));
                % generate sequence object.  It will find and append the
                % proper undo gate.
                sequences(ind)=explib.RB.rbSequence(seqList,obj.cliffords);
            end
            
            
            obj.sequences=sequences;
            % find max duration of all sequences
            d=sequences(mInd).sequenceDuration;
            obj.rbEndTime=obj.pulseCal.startBuffer+d;
            obj.measStartTime=obj.rbEndTime+obj.pulseCal.measBuffer;
            obj.measEndTime=obj.measStartTime+obj.measurement.totalDuration;
            obj.waveformEndTime = obj.measEndTime + obj.pulseCal.endBuffer;
        end
        
        function draw(obj)
            t = 0:1/obj.samplingRate:(obj.waveformEndTime);
            figure(125);
            h1=subplot(2,1,1);
            hold(h1,'on');
            h2=subplot(2,1,2);
            hold(h2,'on');
            for ind=1:length(obj.sequences)
                seq=obj.sequences(ind);
                [iQubitBaseband qQubitBaseband] = seq.uwWaveforms(t, obj.rbEndTime);
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                
                plot(h1,t,iQubitMod+ind*2.5,'b',t,qQubitMod+ind*2.5,'r')
                plot(h2,t,iMeasMod+ind*2.5,'b',t,qMeasMod+ind*2.5,'r')
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %M8195A Direct Download Specific Code
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function playlist = directDownloadM8195A(obj,awg)
            % avoid building full wavesets and WaveLib to save memory 
            % also adding 0 and pi pulse after sequence for normalization
                        
            % clear awg of segments
            iqseq('delete', [], 'keepOpen', 1);
            % check # segments won't be too large
            if length(obj.sequenceLengths+2)>awg.maxSegNumber
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
            % create time axis with correct size
            t = 0:tStep:paddedWaveformEndTime;
            
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
            
            for ind=1:length(obj.sequences)
                display(['loading sequence ' num2str(ind)])
                % create empty baseband wavevectors
                iQubitBaseband = zeros(1,length(t));
                qQubitBaseband = zeros(1,length(t));
                
                s = obj.sequences(ind);
                % find starting point for sequence
                tStart = obj.rbEndTime - s.sequenceDuration;
                startInd = ceil(tStart*obj.pulseCal.samplingRate);
                currentInd = startInd;
                for ind2=1:length(s.pulses)
                    c = s.pulses(ind2);
                    
                    for ind3=1:length(c.primDecomp)
                        p = c.primDecomp(ind3);
                        whichPrimitive = find(eq(p,obj.primitives())); % compares handles and returns index
                        iTemp = obj.iPrimitiveWaveforms(:,whichPrimitive);
                        qTemp = obj.qPrimitiveWaveforms(:,whichPrimitive);
                        stopInd = currentInd + length(iTemp) - 1;
                        
                        iQubitBaseband(currentInd:stopInd) = iTemp;
                        qQubitBaseband(currentInd:stopInd) = qTemp;
                        
                        currentInd = stopInd + 1;
                    end
                end
                
                % RB Sequence object takes END time as an input!
%                 [iQubitBaseband qQubitBaseband] = s.uwWaveforms(t, obj.rbEndTime);
                iQubitMod=cos(2*pi*obj.pulseCal.qubitFreq*t).*iQubitBaseband;
%                 clear iQubitBaseband;
                qQubitMod=sin(2*pi*obj.pulseCal.qubitFreq*t).*qQubitBaseband;
%                 clear qQubitBaseband;
%                 [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
%                 iMeasMod=cos(2*pi*obj.pulseCal.cavityFreq*t).*iMeasBaseband;
%                 clear iMeasBaseband 
%                 qMeasMod=sin(2*pi*obj.pulseCal.cavityFreq*t).*qMeasBaseband;
%                 clear qMeasBaseband;
                ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
%                 clear iQubitMod qQubitMod
                % background is measurement pulse to get contrast
                backgroundWaveform = iMeasMod+qMeasMod;
%                 clear iMeasMod qMeasMod
                
                % now directly loading into awg
                dataId = ind*2-1;
                backId = ind*2;
                % load data segment
                iqdownload(ch1waveform,awg.samplerate,'channelMapping',[1 0; 0 0; 0 0; 0 0],'segmentNumber',dataId,'keepOpen',1,'run',0,'marker',markerWaveform);
%                 clear ch1waveform;
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
            
            % now that sequences are loaded, add the 0
            % pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            display('loading normalization I pulse');
            ig = obj.primitives(1);
            tCenter = obj.rbEndTime - ig.totalDuration/2;
            [iQubitBaseband qQubitBaseband] = ig.uwWaveforms(t, tCenter);
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
            clear iMeasMod qMeasMod
            
            % now directly loading into awg
            dataId = ind*2+1;
            backId = ind*2+2;
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
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            display('loading normalization X180 pulse');
            ig = obj.primitives(2);
            tCenter = obj.rbEndTime - ig.totalDuration/2;
            [iQubitBaseband qQubitBaseband] = ig.uwWaveforms(t, tCenter);
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
            clear iMeasMod qMeasMod
            
            % now directly loading into awg
            dataId = ind*2+3;
            backId = ind*2+4;
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
                
                % normalize amplitude
                xaxisNorm=obj.sequenceLengths; % 
                amp=sqrt(Pint);
                norm0=amp(end-1);
                norm1=amp(end);
                normRange=norm1-norm0;
                AmpNorm=(amp(1:end-2)-norm0)/normRange;

                timeString = datestr(datetime);
                if ~mod(ind,10)
                    figure(753);
                    subplot(2,3,[1 2 3]); 
                    plot(xaxisNorm, AmpNorm);
                    plotlib.hline(0);
                    plotlib.hline(1);
                    title([obj.experimentName ' ' timeString '  SoftAvg = ' num2str(ind) '/ ' num2str(softavg)]);
                    ylabel('Normalized Amplitude'); xlabel('Clifford Sequence Length');
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
            figure(753);
            subplot(2,3,[1 2 3]);
            plot(xaxisNorm, AmpNorm);
            plotlib.hline(0);
            plotlib.hline(1);
            title([obj.experimentName ' ' timeString '  SoftAvg = ' num2str(ind) '/ ' num2str(softavg)]);
            ylabel('Normalized Amplitude'); xlabel('Clifford Sequence Length');
            
            result.taxis = taxis;
            result.xaxisNorm = xaxisNorm;
            result.Idata=Idata./softavg;
            result.Qdata=Qdata./softavg;
            result.Pdata=Pdata./softavg;
            result.Pint=Pint./softavg;
            result.AmpNorm = AmpNorm;
            display('Experiment Finished')
        end
        
        
    end
end
       