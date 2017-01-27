function dataArray = ReadChannels64(self, chList)
% Read the channels specified by chList

    params = self.params;  % Get params all at once
                           % avoid using self.params below because it will
                           % call self.GetParams() and waste time
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
    % Save origin channel settings                           
    channelList={'Channel1', 'Channel2', 'Channel3', 'Channel4',...
               'Channel5', 'Channel6', 'Channel7', 'Channel8'};
    
    % Check channel list
    if min(chList) < 1 || max(chList) > 8
        display('Error: channel number needs to be between 1 and 8');
        return;
    end
    if ~isequal(chList, unique(chList))
        display('Warning: duplicate channel numbers in chList');
    end
    
    
    if strcmp(params.couplemode, 'DC')
      coupling = 1;
    elseif strcmp(params.coupledmode, 'AC')
       coupling = 0;
    else
       display('Unknow couplemode');
    end

    % Enable ChI and ChQ
    for ch = 1:8
        pCh = 1:8;
        if ismember(pCh(ch), chList)
            enabled = 1;
        else
            enabled = 0;
        end
%         pCh.Configure(params.fullscale, params.offset, coupling, enabled);
        invoke(self.instrID.Configurationchannel, 'configurechannel', channelList{ch},...
            params.fullscale, params.offset, coupling, enabled);
    end
 
    % Set the acquisition parameters
    invoke(self.instrID.Configurationacquisition, 'configureacquisition',...
        1, params.samples, params.samplerate);

    %Size waveform arrays as required
    arraySize =...
        invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
        'queryminwaveformmemory',16,1,0,params.samples);
    
    inArray = zeros(arraySize,1);
    dataArray = zeros(length(chList), round(params.samples));
    
%     disp('Measuring ...');
    
    % Initialize the acquisition
    invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
        'initiateacquisition');
    
    % Set the trigger source, and trigger type
    invoke(self.instrID.Configurationtrigger,'configureedgetriggersource',...
        params.trigSource, params.trigLevel, 1);
    
    % Wait for maximum 1 second for the acquisition to complete,
    try
        invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
            'waitforacquisitioncomplete', 1500);
    catch exception
        % if there is no trigger, send a software trigger
        invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
            'sendsoftwaretrigger');
        disp('No trigger detected on module 1, forcing software trigger');
        invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
            'waitforacquisitioncomplete', 1500);
    end
    
    % Fetch the acquisition waveform data
    counter=1;
    for index = 1:8
        if ismember(pCh(index), chList)
            [inArray,ActualPoints1,FirstValidPoint1,...
                InitialXOffset1,InitialXTimeSeconds1,InitialXTimeFraction1,...
                XIncrement, ScaleFactor, ScaleOffset] = ...
                invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
                'fetchwaveformint16',channelList{index},arraySize,inArray);
            
            % Convert data to Volts.
            for i=1+FirstValidPoint1:FirstValidPoint1+ActualPoints1
                inArray(i) = inArray(i) * ScaleFactor + ScaleOffset;
            end;
            
            dataArray(counter, :) = inArray(1+FirstValidPoint1:FirstValidPoint1+ActualPoints1)';
            counter=counter+1;
        end
        
        
    end
%     disp('Measurement Complete ...');
        
    % Enable ChI and ChQ
    for ch = 1:8
        pCh = 1:8;
        if ismember(pCh(ch), [1 2])
            enabled = 1;
        else
            enabled = 0;
        end
%         pCh.Configure(params.fullscale, params.offset, coupling, enabled);
        invoke(self.instrID.Configurationchannel, 'configurechannel', channelList{ch},...
            params.fullscale, params.offset, coupling, enabled);
    end
    
end
