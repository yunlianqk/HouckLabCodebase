classdef SingleShot2DHistograms < handle
    % alternate between trials in the ground state and trials in the
    % excited. Keep single shot data and histogram them.
    
    properties 
        experimentName = 'SingleShot2DHistograms';
        % inputs
        pulseCal;
        trials = 20000; % total number of single shots to collect
        bins = 100; % histogram bins
        doPlot = 1;
        % Dependent properties auto calculated in the update method
        qubit; % qubit pulse object
        measurement; % measurement pulse object
        qubitPulseTime;
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=SingleShot2DHistograms(pulseCal,varargin)
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
            softAverages = ceil(obj.trials/cardparams.averages);
            
%             fidelityStability = zeros(1,softAverages); % preallocate vector to track approach to stable fidelity
%             thresholdStability = zeros(1,softAverages); % preallocate vector to track approach to stable fidelity
%             windowStability = zeros(1,softAverages); % preallocate vector to track approach to stable fidelity
            timeString = datestr(datetime);
            for ind = 1:softAverages
                % READ
                [Idata, Qdata] = card.ReadIandQsingleShot(awg,playlist);
                Idata=Idata(1:cardparams.samples,:);
                Qdata=Qdata(1:cardparams.samples,:);
                % separate and integrate I and Q for histograms                
                Ivals = sum(Idata)./cardparams.samples;
                exIvals = Ivals(1:2:end);
                gndIvals = Ivals(2:2:end);
                Qvals = sum(Qdata)./cardparams.samples;
                exQvals = Qvals(1:2:end);
                gndQvals = Qvals(2:2:end);
                % calculate amp and phase
                exAvals = sqrt(exIvals.^2 +exQvals.^2);
                gndAvals = sqrt(gndIvals.^2 +gndQvals.^2);
                exPvals = atan(exQvals./exIvals);
                gndPvals = atan(gndQvals./gndIvals);
                
                
                
                %%
                %use first soft average determine bins and preallocate
                if ind == 1
                    % make bins
                    Imin = min(min([gndIvals exIvals]));
                    Imax = max(max([gndIvals exIvals]));
                    Qmin = min(min([gndQvals exQvals]));
                    Qmax = max(max([gndQvals exQvals]));
                    Amin = min(min([gndAvals exAvals]));
                    Amax = max(max([gndAvals exAvals]));
                    Pmin = min(min([gndPvals exPvals]));
                    Pmax = max(max([gndPvals exPvals]));
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
                    gndBivHist = zeros(obj.bins+1,obj.bins+1);
                    exBivHist = zeros(obj.bins+1,obj.bins+1);
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
                
                
                %% sweet bivariate histogram
                gndBivData=[gndIvals' gndQvals'];
                exBivData=[exIvals' exQvals'];
                gndBivHistTemp = hist3(gndBivData,bivEdges);
                exBivHistTemp = hist3(exBivData,bivEdges);
                gndBivHist = gndBivHist + gndBivHistTemp';
                exBivHist = exBivHist + exBivHistTemp';                
                
                
                %%
                %if doPlot is 1, do all calculations and plots inside loop
                if obj.doPlot == 1
                    
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
                    
                    subplot(1,2,1)
                    imagesc([Iedges(1) Iedges(end)],[Qedges(1) Qedges(end)],gndBivHist);
                    axis square
                    title('gnd')
                    subplot(1,2,2)
                    imagesc([Iedges(1) Iedges(end)],[Qedges(1) Qedges(end)],exBivHist);
                    axis square
                    title('ex');
                    drawnow
                    
%                     
%                     
%                     gndCDF = cumsum(gndHistograms);
%                     gndCDF = gndCDF/gndCDF(end,end);
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


        
        
        