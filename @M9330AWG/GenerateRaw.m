function GenerateRaw(self, waveforms, markers)
% Low level method for waveform generation

% waveforms: 
%       A (2 by N) array containing the waveforms.
%       The data points are integers (int16) ranging from -32768 to +32767. 
%       Number of data points has to be multiple of 8.

% markers:
%       A (2 by N) array containing the markerss.
%       One marker value must be supplied for each waveform samples.
%       Each marker value is specified in a byte (uint8), where the two 
%       most significant bits are extracted and used as markers. 
%       Bit 6 is marker1 and bit 7 is marker2.
%       markers(:, 1:8:end) is then passed to the instrument according
%       to method 2) below.
%
% There are three ways the marker data may be presented:
% 1) Pass a null pointer for the marker data (no markers).
% 2) Pass a marker array that is 1/8th of the waveform size,
%    and thus has one maker value for each 8 waveform samples.
%    This matches the resolution of marker data in the current product release.
% 3) Pass one marker value for each waveform sample.
%    Internally, each 8 marker values will be logically OR'ed together to
%    produce one actual marker sample for each 8 waveform samples.

    self.instrhandle.AbortGeneration();

    device = self.instrhandle.DeviceSpecific;
    device.Output.OutputMode = 2; % 1 = single waveform
                                  % 2 = sequence
                                  % 3 = advanced sequence, not implemented yet
    device.Arbitrary.Sequence.ClearAll();
    device.Arbitrary.Waveform.ClearAll();
    device.Arbitrary.Waveform.Predistortion.Enabled = false;

    for ch = 1:2
        % Set 'Arbitrary' properties
        % Markers need to be fed as a COLUMN vector
        wavehandle = device.Arbitrary.Waveform.CreateRaw(waveforms(ch, :), ...
                                                         markers(ch, 1:8:end)');
        device.Arbitrary.Waveform.Handle(num2str(ch), wavehandle);
        device.Output.Configuration(num2str(ch), self.OUTPUTCONFIG);
        switch self.OUTPUTCONFIG
            case 0
                % Single-ended output
                device.Arbitrary.Gain(num2str(ch), 0.25);
            case 1
                % Differential output
                device.Arbitrary.Gain(num2str(ch), 0.5);
            case 2
                % Amplified single-ended output
                device.Arbitrary.Gain(num2str(ch), 0.5);    
        end
        % Set 'Output' properties
        device.Output.Enabled(num2str(ch), true);
        device.Output.OperationMode(num2str(ch), 1); % 0 = continuous
                                                     % 1 = burst based on trigger
        device.Output.FilterEnabled(num2str(ch), false);
        % Set 'Trigger' properties
        device.Trigger.BurstCount(num2str(ch), 1);  % Number of waveform cycles after receiveing a trigger               
        device.Trigger.Source(num2str(ch), 2^self.TRIGINPORT);
    end
    % Set 'Marker' properties
    device.Marker.ActiveMarker = '1';
    if self.mkrauto
        device.Marker.PulseWidth = 100e-9;
        device.Marker.Source = 10;
    else
        device.Marker.Source = 2;
    end
    for port = 2:4
        device.Marker.ActiveMarker = num2str(port);
        device.Marker.Source = port+1;
    end

    self.instrhandle.InitiateGeneration();
end
