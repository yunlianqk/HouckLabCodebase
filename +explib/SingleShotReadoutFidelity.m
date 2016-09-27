classdef SingleShotReadoutFidelity < handle
    % alternate between trials in the ground state and trials in the
    % excited. Keep single shot data and histogram them.
    
    properties 
        experimentName = 'SingleShotReadoutFidelity';
        % inputs
        pulseCal;
        trials;
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
        function obj=SingleShotReadoutFidelity(pulseCal,varargin)
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
                    obj.doPlot = varargin{2};
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
        softwareRepeats = 1; % to collect more trials
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
            cardparams.averages=obj.trials;  % software averages PER SEGMENT
            cardparams.segments = length(playlist);
            cardparams.delaytime = obj.measStartTime + obj.pulseCal.cardDelayOffset;
            card.SetParams(cardparams);
%             tstep=1/card.params.samplerate;
%             taxis=(tstep:tstep:card.params.samples/card.params.samplerate)'./1e-6;%mus units
            
            % READ
            [Idata, Qdata] = card.ReadIandQsingleShot(awg,playlist);
            Idata=Idata(1:cardparams.samples,:);
            Qdata=Qdata(1:cardparams.samples,:);
            Adata = sqrt(Idata.^2+Qdata.^2);
            
            % trying all different integration windows
            Icumsum = cumsum(Idata)./repmat((1:cardparams.samples)',1,cardparams.averages*2);
            Qcumsum = cumsum(Qdata)./repmat((1:cardparams.samples)',1,cardparams.averages*2);
            Acumsum = cumsum(Adata)./repmat((1:cardparams.samples)',1,cardparams.averages*2);
            % extracting excited and ground states
            exCumsum = Acumsum(:,1:2:end);
            gndCumsum = Acumsum(:,2:2:end);
            % finding threshold and fidelity for all possible windows
            % sort to create cumulative distribution function
            gndCDF=sort(gndCumsum,2);
            exCDF=sort(exCumsum,2);
            yvals = (1:size(gndCDF,2))./size(gndCDF,2);
            % find max voltage range over which to do interpolation
            xstart = min([gndCDF(:,1); exCDF(:,1)]);
            xstop = max([gndCDF(:,end); exCDF(:,end)]);
            denseCDFxaxis = linspace(xstart,xstop,300);
            % do interpolation for each window
%             gndCDFSmooth = zeros(size(gndCDF,1),length(denseCDFxaxis));
%             exCDFSmooth = zeros(size(gndCDF,1),length(denseCDFxaxis));
            gndCDFSmooth = zeros(size(gndCDF,1),length(denseCDFxaxis))';
            exCDFSmooth = zeros(size(gndCDF,1),length(denseCDFxaxis))';
            for ind2 = 2:1:size(gndCDF,1)
%                 gndCDFsmooth(ind2,:) = interp1(gndCDF(ind2,:),yvals,denseCDFxaxis,'nearest','extrap');
%                 exCDFsmooth(ind2,:) = interp1(exCDF(ind2,:),yvals,denseCDFxaxis,'nearest','extrap');
                gndCDFsmooth(:,ind2) = interp1(gndCDF(ind2,:),yvals,denseCDFxaxis,'nearest','extrap');
                exCDFsmooth(:,ind2) = interp1(exCDF(ind2,:),yvals,denseCDFxaxis,'nearest','extrap');
            end
            gndCDFsmooth=gndCDFsmooth';
            exCDFsmooth=exCDFsmooth';
            % subract to find fidelity and threshold
            CDFdiff=gndCDFsmooth-exCDFsmooth;
            [fidelity, threshInd] = max(CDFdiff,[],2);
            thresholds = denseCDFxaxis(threshInd);
            % locate optimum window
            [optimalFidelity, optimalWindow] = max(fidelity);
            optimalThreshold = thresholds(optimalWindow);
            gndOptCDF=gndCDF(optimalWindow,:);
            exOptCDF=exCDF(optimalWindow,:);
            
            
            if obj.doPlot
                timeString = datestr(datetime);
                % plot results
                figure(691);
                subplot(1,3,1)
                histogram(gndOptCDF),hold on
                histogram(exOptCDF),hold off
                plotlib.vline(optimalThreshold)
                title([obj.experimentName ' ' timeString])
                xlabel('Integrated Voltage')
                ylabel('Single Shot Count')
                subplot(1,3,2)
                plot(gndOptCDF,yvals,'b.',exOptCDF,yvals,'r.')
                plotlib.vline(optimalThreshold)
                xlabel('Integrated Voltage')
                ylabel('Cumulative Distribution Functions')
                title(['Fidelity: ' num2str(optimalFidelity) ' Threshold: ' num2str(optimalThreshold)])
                subplot(1,3,3)
                plot(fidelity(2:end))
                plotlib.vline(optimalWindow)
                xlabel('Samples in Window')
                ylabel('Cumulative Distribution Functions')
                title(['Optimal Samples: ' num2str(optimalWindow)])
            end
            
            result.optimalFidelity = optimalFidelity;
            result.optimalWindow = optimalWindow;
            result.optimalThreshold = optimalThreshold;
            result.fidelity = fidelity;
            result.threshold = thresholds;
            result.gndOptCDF = gndOptCDF;
            result.exOptCDF = exOptCDF;

            display('Experiment Finished')
         end
    end
end


        
        
        