function Generate(pulsegen, waveforms, markers)
% Low level code for waveform generation
% WaveformData: The array of data containing the waveform. 
% The data points range from -32768 to +32767. 

% MarkerData: One marker value must be supplied for each 8 waveform samples.
% Each marker value is specified in a byte, where the two most significant bits
% are extracted and used as markers. Bit 6 is marker1 and bit 7 is marker2.
% There are three ways the marker data may be presented:
% 1) Pass a null pointer for the marker data (no markers).
% 2) Pass a marker array that is 1/8th of the waveform size,
% and thus has one maker value for each 8 waveform samples.
% This matches the resolution of marker data in the current product release.
% 3) Pass one marker value for each waveform sample.
% Internally, each 8 marker values will be logically OR'ed together to
% produce one actual marker sample for each 8 waveform samples.

    % Waveform amplitudes are normalized to maxamp
    waveforms = int16([waveforms(1,:) * pulsegen.ch1maxamp; 
                       waveforms(2,:) * pulsegen.ch2maxamp]);
    % markers(1,:) defines channel 1 marker 1,
    % markers(2,:) defines channel 2 marker 1
    markers = uint8([markers(1,1:8:end)*2^6; markers(2,1:8:end)*2^6]);

    pulsegen.instrhandle.AbortGeneration();

    handle = pulsegen.instrhandle.DeviceSpecific;
    handle.Arbitrary.Waveform.ClearAll();
    handle.Arbitrary.Sequence.ClearAll();
    handle.Arbitrary.Waveform.Predistortion.Enabled = false;
    handle.Output.OutputMode = 1;   % 1 = single waveform, 2 = sequence
    handle.Trigger.ActiveTrigger = num2str(pulsegen.triggerinport);
    for ch = 1:2
        % Set 'Arbitrary' properties
        % Markers need to be fed as a COLUMN vector
        wavehandle = handle.Arbitrary.Waveform.CreateRaw(waveforms(ch,:), markers(ch, :)');
        handle.Arbitrary.Waveform.Handle(num2str(ch), wavehandle);
        handle.Output.Configuration(num2str(ch), pulsegen.outputconfiguration);
        switch pulsegen.outputconfiguration
            case 0
                handle.Arbitrary.Gain(num2str(ch), 0.5);
            case 1
                handle.Arbitrary.Gain(num2str(ch), 0.25);
            case 2
                handle.Arbitrary.Gain(num2str(ch), 0.5);    
        end
        % Set 'Output' properties
        handle.Output.Enabled(num2str(ch), true);
        handle.Output.OperationMode(num2str(ch), 1); % 0 = continuous
                                                     % 1 = burst based on trigger
        handle.Output.FilterEnabled(num2str(ch), false);
        % Set 'Trigger' properties
        handle.Trigger.BurstCount(num2str(ch), 1);  % Number of waveform cycles after receiveing a trigger               
    end
    % Set 'Marker' properties
    handle.Marker.ActiveMarker = num2str(pulsegen.triggeroutport);
    handle.Marker.PulseWidth = 100e-9;
    handle.Marker.Source = 9;

    handle.Marker.ActiveMarker = num2str(pulsegen.marker1port);
    handle.Marker.Source = 2;

    handle.Marker.ActiveMarker = num2str(pulsegen.marker2port);
    handle.Marker.Source = 4;

    pulsegen.instrhandle.InitiateGeneration();
end