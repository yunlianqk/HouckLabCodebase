function Generate(self)
% Load waveforms, create markers and generate output

    % Auto generate markers
    if self.mkrauto
        % marker2 for waveform1, marker4 for waveform2
        self.marker2 = double(self.waveform1 ~= 0);
        self.marker4 = double(self.waveform2 ~= 0);
        if length(self.marker1) ~= length(self.marker2)
            self.marker1 = zeros(1, length(self.waveform1));
        end
        if length(self.marker3) ~= length(self.marker2)
            self.marker3 = zeros(1, length(self.waveform1));
        end
    end
    % If waveform and marker lengths are note equal, throw error
    for len = [length(self.waveform1), length(self.waveform2), ...
               length(self.marker1), length(self.marker2), ...
               length(self.marker3), length(self.marker4)]
        if len ~= length(self.timeaxis)
            error('Waveforms, markers and timeaxis should have same length');
        end
    end
    % If waveform lengths are less than 128, throw error
    if length(self.waveform1) < 128
        error('Waveforms should contain at least 128 points');
    end
    % Stack waveforms and markers together for easier manipulation
    waveforms = [self.waveform1; self.waveform2];
    markers = [self.marker1; self.marker2; self.marker3; self.marker4];
    % Interpolate time axis and waveforms using sampling rate
    dt = 1/self.samplingrate;
    taxis = self.timeaxis(1):dt:self.timeaxis(end);
    waveforms = interp1(self.timeaxis, waveforms', taxis)';
    markers = interp1(self.timeaxis, double(markers)', taxis)';
    % Increase the length of time axis and waveforms to integer mulitple of 8
    newlength = ceil(length(waveforms(1, :))/8)*8;
    waveforms(:, newlength) = 0;
    markers(:, newlength) = 0;
    % Force marker to be 0/1
    markers = double(markers ~= 0);

    % Create rawdata points for AWG
    fullscale = 32767;
    for ch = 1:2
        % Normalize waveforms if max value > 1.0
        maxvalue = max(abs(waveforms(ch, :)));
        if maxvalue > 1.0
            waveforms(ch, :) = waveforms(ch, :)/maxvalue;
        end
        % Rescale waveforms to fullscale
        waveforms(ch, :) = waveforms(ch, :) * fullscale;
        if self.mkrauto
            % Increase marker width by 2*mkrbuffer
            for index = find(diff(markers(2*ch,:))) % Find all jumps in marker
                if (markers(2*ch, index) == 0)    % Rising edge
                    markers(2*ch, max(1, index-self.mkrbuffer+1):index) = 1;
                else % Falling edge
                    markers(2*ch, index+1:min(newlength, index+self.mkrbuffer)) = 1;
                end
            end
            % Shift marker by mkroffset
            if self.mkroffset >= 0
                markers(2*ch, :) = [zeros(1, self.mkroffset), ...
                                    markers(2*ch, 1:end-self.mkroffset)];
            else
                markers(2*ch, :) = [markers(2*ch, 1-self.mkroffset:end), ...
                                    zeros(1, -self.mkroffset)];
            end
        end
    end
    % Convert to raw data forms
    waveforms = int16(waveforms);
    markers = uint8(markers(1:2:3, :)*2^6 + markers(2:2:4, :)*2^7);
    % Generate waveforms
    self.GenerateRaw(waveforms, markers);
end