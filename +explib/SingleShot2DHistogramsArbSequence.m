classdef SingleShot2DHistogramsArbSequence < handle
    % alternate between trials in the ground state and trials in the
    % excited. Keep single shot data and histogram them.
    
    properties 
        experimentName = 'SingleShot2DHistogramsArbSequence';
        % inputs
        pulseCal;
        trials = 20000; % total number of single shots to collect
        bins = 100; % histogram bins
        doPlot = 1;
%         rabiDrive=.15;
        rabiDrive=1;
%         rabiDrive=0;
%         rabiDuration=.480e-6;
        rabiDuration=200e-6;
        measDelay = 0;
        % Dependent properties auto calculated in the update method
        qubit; % qubit pulse object
        measurement; % measurement pulse object
        rabi; % rabi pulse object
        qubitPulseTime;
        rabiPulseTime;
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=SingleShot2DHistogramsArbSequence(pulseCal,varargin)
            % constructor. Overwrites ampVector if it is passed as an input
            % then calls the update function to calculate dependent
            % properties. If these are changed after construction, rerun
            % update method.
            obj.pulseCal = pulseCal;
            nVarargs = length(varargin);
            switch nVarargs
                case 1
                    obj.trials = varargin{1};
                case 2
                    obj.trials = varargin{1};
                    obj.bins = varargin{2};
                case 3
                    obj.trials = varargin{1};
                    obj.bins = varargin{2};
                    obj.doPlot = varargin{3};
            end
            obj.update();
        end
    
        function obj=update(obj)
            % run this to update dependent parameters after changing
            % experiment details
%             obj.qubit = obj.pulseCal.X180();
            obj.qubit = obj.pulseCal.X90();
            obj.rabi = pulselib.measPulse(obj.rabiDuration,obj.rabiDrive);
%             obj.qubit = obj.pulseCal.Identity();
            obj.measurement = obj.pulseCal.measurement();
%             obj.measStartTime = obj.pulseCal.startBuffer+obj.rabi.totalDuration+obj.qubit.totalDuration;
            obj.measStartTime = obj.pulseCal.startBuffer+obj.rabi.totalDuration+obj.qubit.totalDuration+obj.measDelay;
            obj.qubitPulseTime = obj.measStartTime-obj.pulseCal.measBuffer-obj.qubit.totalDuration/2;
            obj.rabiPulseTime = obj.measStartTime-obj.pulseCal.measBuffer-obj.rabi.totalDuration;
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
%             clear iMeasMod qMeasMod
            %generate Rabi segment
            r = obj.rabi;
            [iRabiBaseband qRabiBaseband] = r.uwWaveforms(t, obj.rabiPulseTime);
            iRabiMod=cos(2*pi*obj.pulseCal.qubitFreq*t).*iRabiBaseband;
            clear rQubitBaseband;
            qRabiMod=sin(2*pi*obj.pulseCal.qubitFreq*t).*qRabiBaseband;
            clear rQubitBaseband;
            rabiWaveform = iRabiMod+qRabiMod+iMeasMod+qMeasMod;
            clear iMeasMod qMeasMod
            
            
            % now directly loading into awg
            dataId = 1;
            backId = 2;
            rabiId = 3;
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
            % load Rabi segment
            iqdownload(rabiWaveform,awg.samplerate,'channelMapping',[1 0; 0 0; 0 0; 0 0],'segmentNumber',rabiId,'keepOpen',1,'run',0,'marker',markerWaveform);
            clear rabiWaveform;
            % load lo segment
            iqdownload(loWaveform,awg.samplerate,'channelMapping',[0 0; 1 0; 0 0; 0 0],'segmentNumber',rabiId,'keepOpen',1,'run',0,'marker',markerWaveform);
            % create Rabi playlist entry
            playlist(rabiId).segmentNumber = rabiId;
            playlist(rabiId).segmentLoops = 1;
            playlist(rabiId).markerEnable = true;
            playlist(rabiId).segmentAdvance = 'Stepped';
            % last playlist item must have advance set to 'auto'
            playlist(rabiId).segmentAdvance = 'Auto';
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
            softAverages = ceil(obj.trials/cardparams.averages);
            
%             fidelityStability = zeros(1,softAverages); % preallocate vector to track approach to stable fidelity
%             thresholdStability = zeros(1,softAverages); % preallocate vector to track approach to stable fidelity
%             windowStability = zeros(1,softAverages); % preallocate vector to track approach to stable fidelity
            timeString = datestr(datetime);
            time=fix(clock);
            for ind = 1:softAverages
                % READ
                [Idata, Qdata] = card.ReadIandQsingleShot(awg,playlist);
                Idata=Idata(1:cardparams.samples,:);
                Qdata=Qdata(1:cardparams.samples,:);
                % separate and integrate I and Q for histograms                
                Ivals = sum(Idata)./cardparams.samples;
                exIvals = Ivals(1:3:end);
                gndIvals = Ivals(2:3:end);
                rabiIvals = Ivals(3:3:end);
                Qvals = sum(Qdata)./cardparams.samples;
                exQvals = Qvals(1:3:end);
                gndQvals = Qvals(2:3:end);
                rabiQvals = Qvals(3:3:end);
                % calculate amp and phase
                exAvals = sqrt(exIvals.^2 +exQvals.^2);
                gndAvals = sqrt(gndIvals.^2 +gndQvals.^2);
                rabiAvals = sqrt(rabiIvals.^2+rabiQvals.^2);
                exPvals = atan(exQvals./exIvals);
                gndPvals = atan(gndQvals./gndIvals);
                rabiPvals = atan(rabiQvals./rabiIvals);
                
                
                
                %%
                %use first soft average determine bins and preallocate
                if ind == 1
                    % make bins
                    Imin = min(min([gndIvals exIvals rabiIvals]));
                    Imax = max(max([gndIvals exIvals rabiIvals]));
                    Qmin = min(min([gndQvals exQvals rabiQvals]));
                    Qmax = max(max([gndQvals exQvals rabiQvals]));
                    Amin = min(min([gndAvals exAvals rabiAvals]));
                    Amax = max(max([gndAvals exAvals rabiAvals]));
                    Pmin = min(min([gndPvals exPvals rabiPvals]));
                    Pmax = max(max([gndPvals exPvals rabiPvals]));
                    Iedges = linspace(Imin,Imax,obj.bins+1);
                    Qedges = linspace(Qmin,Qmax,obj.bins+1);
                    Aedges = linspace(Amin,Amax,obj.bins+1);
                    Pedges = linspace(Pmin,Pmax,obj.bins+1);
                    bivEdges{1}=Iedges;
                    bivEdges{2}=Qedges;
                    % preallocate histogram matrix
                    gndIHist = zeros(1,obj.bins);
                    gndQHist = zeros(1,obj.bins);
                    gndAHist = zeros(1,obj.bins);
                    gndPHist = zeros(1,obj.bins);
                    exIHist = zeros(1,obj.bins);
                    exQHist = zeros(1,obj.bins);
                    exAHist = zeros(1,obj.bins);
                    exPHist = zeros(1,obj.bins);
                    rabiIHist = zeros(1,obj.bins);
                    rabiQHist = zeros(1,obj.bins);
                    rabiAHist = zeros(1,obj.bins);
                    rabiPHist = zeros(1,obj.bins);
                    gndBivHist = zeros(obj.bins+1,obj.bins+1);
                    exBivHist = zeros(obj.bins+1,obj.bins+1);
                    rabiBivHist = zeros(obj.bins+1,obj.bins+1);
                end
                
                [counts,~] = histcounts(gndIvals,Iedges);
                gndIHist=gndIHist+counts;
                [counts,~] = histcounts(gndQvals,Qedges);
                gndQHist=gndQHist+counts;
                [counts,~] = histcounts(gndAvals,Aedges);
                gndAHist=gndAHist+counts;
                [counts,~] = histcounts(gndPvals,Pedges);
                gndPHist=gndPHist+counts;
                [counts,~] = histcounts(exIvals,Iedges);
                exIHist=exIHist+counts;
                [counts,~] = histcounts(exQvals,Qedges);
                exQHist=exQHist+counts;
                [counts,~] = histcounts(exAvals,Aedges);
                exAHist=exAHist+counts;
                [counts,~] = histcounts(exPvals,Pedges);
                exPHist=exPHist+counts;
                [counts,~] = histcounts(rabiIvals,Iedges);
                rabiIHist=rabiIHist+counts;
                [counts,~] = histcounts(rabiQvals,Qedges);
                rabiQHist=rabiQHist+counts;
                [counts,~] = histcounts(rabiAvals,Aedges);
                rabiAHist=rabiAHist+counts;
                [counts,~] = histcounts(rabiPvals,Pedges);
                rabiPHist=rabiPHist+counts;
                
                %% sweet bivariate histogram
                gndBivData=[gndIvals' gndQvals'];
                exBivData=[exIvals' exQvals'];
                rabiBivData=[rabiIvals' rabiQvals'];
                gndBivHistTemp = hist3(gndBivData,bivEdges);
                exBivHistTemp = hist3(exBivData,bivEdges);
                rabiBivHistTemp = hist3(rabiBivData,bivEdges);
                gndBivHist = gndBivHist + gndBivHistTemp';
                exBivHist = exBivHist + exBivHistTemp';
                rabiBivHist = rabiBivHist + rabiBivHistTemp';
                
                
                %%
                %if doPlot is 1, do all calculations and plots inside loop
                if obj.doPlot == 1 && (mod(ind,10)==0)
                    
                    %%
                    
                    figure(115)
%                     subplot(2,2,1)
%                     hist3(gndBivData,'Edges',bivEdges);
%                     title('gnd')
%                     subplot(2,2,2)
%                     hist3(exBivData,'Edges',bivEdges);
%                     title('ex')
                    
%                     gndBivHist = hist3(gndBivData,bivEdges);
%                     exBivHist = hist3(exBivData,bivEdges);
                    
                    subplot(2,2,1)
                    imagesc([Iedges(1) Iedges(end)],[Qedges(1) Qedges(end)],gndBivHist);
                    axis square
                    title(['gnd: N=' num2str(ind)])
                    subplot(2,2,2)
                    imagesc([Iedges(1) Iedges(end)],[Qedges(1) Qedges(end)],exBivHist);
                    axis square
                    title('ex');
                    subplot(2,2,3)
                    imagesc([Iedges(1) Iedges(end)],[Qedges(1) Qedges(end)],rabiBivHist);
                    axis square
                    title(['Rabi drive with amplitude = ' num2str(obj.rabiDrive) ' and duration = ' num2str(obj.rabiDuration/1e-6) ' mus']);
                    subplot(2,2,4)
                    imagesc([Iedges(1) Iedges(end)],[Qedges(1) Qedges(end)],rabiBivHist-exBivHist);
                    axis square
                    title('Rabi exp - X180 exp');
                    drawnow
                    
                    figure(117)
                    plot(Aedges(1:end-1),gndAHist,'b',Aedges(1:end-1),exAHist,'r',Aedges(1:end-1),rabiAHist,'g');
                    title('Amp histograms b=gnd, r=ex, g=rabi')
                    
                    result.IEdges = Iedges;
                    result.QEdges = Qedges;
                    result.AEdges = Aedges;
                    result.PEdges = Pedges;
                    result.bivEdges = bivEdges;
                    result.gndIHist = gndIHist;
                    result.gndQHist = gndQHist;
                    result.gndAHist = gndAHist;
                    result.gndPHist = gndPHist;
                    result.gndBivHist = gndBivHist;
                    result.exIHist = exIHist;
                    result.exQHist = exQHist;
                    result.exAHist = exAHist;
                    result.exPHist = exPHist;
                    result.exBivHist = exBivHist;
                    result.rabiIHist = rabiIHist;
                    result.rabiQHist = rabiQHist;
                    result.rabiAHist = rabiAHist;
                    result.rabiPHist = rabiPHist;
                    result.rabiBivHist = rabiBivHist;
                    
                    save(['C:\Data\' obj.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
                    'result');
%                     

%                     
%                     gndCDF = cumsum(gndHistograms);
%                     gndCDF = gndCDF/gndCDF(eand,end);
%                     exCDF = cumsum(exHistograms);
%                     exCDF = exCDF/exCDF(end,end);
%                     CDFdiff = gndCDF-exCDF;
%                     [fidelity, threshInd] = max(CDFdiff,[],1);
%                     [optimalFidelity, optimalWindow] = max(fidelity);
%                     optimalThresholdInd = threshInd(optimalWindow);
%                     optimalThreshold = (edges(optimalThresholdInd)+edges(optimalThresholdInd+1))/2;
%                     fidelityStability(ind) = optimalFidelity;
%                     thresholdStability(ind) = optimalThreshold;
%                     windowStability(ind) = optimalWindow;
%                     gndOptHist=gndHistograms(:,optimalWindow);
%                     exOptHist=exHistograms(:,optimalWindow);
%                     gndOptCDF=gndCDF(:,optimalWindow);
%                     exOptCDF=exCDF(:,optimalWindow);
%                     
%                     % plot results
%                     figure(691);
%                     subplot(2,2,1)
%                     plot(edges(2:end),gndOptHist,'b.-',edges(2:end),exOptHist,'r.-')
%                     plotlib.vline(optimalThreshold)
%                     title([obj.experimentName ' ' timeString])
%                     xlabel('Integrated Voltage')
%                     ylabel('Single Shot Count')
%                     subplot(2,2,2)
%                     plot(edges(2:end),gndOptCDF,'b',edges(2:end),exOptCDF,'r')
%                     plotlib.vline(optimalThreshold)
%                     xlabel('Integrated Voltage')
%                     ylabel('Cumulative Distribution Functions')
%                     title(['Fidelity: ' num2str(optimalFidelity) ' Threshold: ' num2str(optimalThreshold)])
%                     subplot(2,2,3)
%                     plot(fidelity)
%                     plotlib.vline(optimalWindow)
%                     xlabel('Samples in Window')
%                     ylabel('Cumulative Distribution Functions')
%                     title(['Optimal Samples: ' num2str(optimalWindow)])
%                     subplot(2,2,4)
%                     [hAx,hLine1,hLine2]=plotyy(1:ind,fidelityStability(1:ind),1:ind,windowStability(1:ind));
%                     ylabel(hAx(1),'Fidelity');
%                     ylabel(hAx(2),'Window');
%                     title('Fidelity, window vs soft averages');
%                     xlabel('Soft averages');
%                     drawnow
                end
                
                
            end
%             
%             % done taking data, do calculations, plot, and return results
%             gndCDF = cumsum(gndHistograms);
%             gndCDF = gndCDF/gndCDF(end,end);
%             exCDF = cumsum(exHistograms);
%             exCDF = exCDF/exCDF(end,end);
%             CDFdiff = gndCDF-exCDF;
%             [fidelity, threshInd] = max(CDFdiff,[],1);
%             [optimalFidelity, optimalWindow] = max(fidelity);
%             optimalThresholdInd = threshInd(optimalWindow);
%             optimalThreshold = (edges(optimalThresholdInd)+edges(optimalThresholdInd+1))/2;
%             gndOptHist=gndHistograms(:,optimalWindow);
%             exOptHist=exHistograms(:,optimalWindow);
%             gndOptCDF=gndCDF(:,optimalWindow);
%             exOptCDF=exCDF(:,optimalWindow);
%             
%             % plot results
%             figure(691);
%             subplot(2,2,1)
%             plot(edges(2:end),gndOptHist,'b.-',edges(2:end),exOptHist,'r.-')
%             plotlib.vline(optimalThreshold)
%             title([obj.experimentName ' ' timeString])
%             xlabel('Integrated Voltage')
%             ylabel('Single Shot Count')
%             subplot(2,2,2)
%             plot(edges(2:end),gndOptCDF,'b',edges(2:end),exOptCDF,'r')
%             plotlib.vline(optimalThreshold)
%             xlabel('Integrated Voltage')
%             ylabel('Cumulative Distribution Functions')
%             title(['Fidelity: ' num2str(optimalFidelity) ' Threshold: ' num2str(optimalThreshold)])
%             subplot(2,2,3)
%             plot(fidelity)
%             plotlib.vline(optimalWindow)
%             xlabel('Samples in Window')
%             ylabel('Cumulative Distribution Functions')
%             title(['Optimal Samples: ' num2str(optimalWindow)])
%             
%             result.optimalFidelity = optimalFidelity;
%             result.optimalWindow = optimalWindow;
%             result.optimalThreshold = optimalThreshold;
%             result.fidelity = fidelity;
%             result.threshInd = threshInd;
%             result.gndOptHist = gndOptHist;
%             result.exOptHist = exOptHist;
%             result.gndOptCDF = gndOptCDF;
%             result.exOptCDF = exOptCDF;
%             result.edges = edges;
%             result.gndHistograms = gndHistograms;
%             result.exHistograms = exHistograms;
            
            result.IEdges = Iedges;
            result.QEdges = Qedges;
            result.AEdges = Aedges;
            result.PEdges = Pedges;
            result.bivEdges = bivEdges;
            result.gndIHist = gndIHist;
            result.gndQHist = gndQHist;
            result.gndAHist = gndAHist;
            result.gndPHist = gndPHist;
            result.gndBivHist = gndBivHist;
            result.exIHist = exIHist;
            result.exQHist = exQHist;
            result.exAHist = exAHist;
            result.exPHist = exPHist;
            result.exBivHist = exBivHist;

            display('Experiment Finished')
         end
    end
end


        
        
        