function SetParams(pulsegen)
% Set up waveforms and markers
    % Check waveform lengths
    if length(pulsegen.waveform1) ~= length(pulsegen.waveform2)
        error('Waveforms need to have same length');
    end
    % Define time axis
    % If time axis is not specified, use default time axis
    if isempty(pulsegen.timeaxis)
        pulsegen.timeaxis = (0:length(pulseparams.waveform1)-1)*pulsegen.samplingrate;
    % If time axis has different length than waveform, throw error
    elseif length(pulsegen.timeaxis) ~= length(pulsegen.waveform1)
        error('Time axis needs to have same length as waveforms');
    end
    % Interpolate time axis and waveforms using sampling rate
    dt = 1/pulsegen.samplingrate;
    taxis = pulsegen.timeaxis(1):dt:pulsegen.timeaxis(end);
    waveforms = [interp1(pulsegen.timeaxis, pulsegen.waveform1, taxis); ...
                 interp1(pulsegen.timeaxis, pulsegen.waveform2, taxis)];
    % Increase the length of time axis and waveforms to integer mulitple of 8
    newlength = ceil(length(waveforms(1,:))/8)*8;
    if mod(length(waveforms(1,:)), 8) ~= 0
        waveforms(1, newlength) = 0;
        waveforms(2, newlength) = 0;
        taxis = linspace(taxis(1), taxis(1)+dt*(newlength-1), newlength);
    end
    
    % Create rawdata sample values for AWG
    markers = zeros(2, length(taxis));
    offset = [pulsegen.mkr1offset, pulsegen.mkr2offset];
    amp = [pulsegen.CH1MAXAMP, pulsegen.CH2MAXAMP];
    for ch = 1:2
        % Waveforms
        % Normalize waveforms if max value > 1.0
        if max(abs(waveforms(ch,:))) > 1.0
            waveforms(ch,:) = waveforms(ch,:)/max(abs(waveforms(ch,:)));
        end
        % Create waveform rawdata for AWG
        waveforms(ch,:) = int16(waveforms(ch,:)*amp(ch));
        
        % Markers
        % Mark none-zero parts of waveform
        markers(ch,:) = (waveforms(ch,:) ~= 0);
        % Find jump positions of marker
        jumpindex = find(diff(markers(ch,:)));
        % Increase marker width by 2*mkraddwidth
        for index = jumpindex
            if (markers(ch, index) == 0)    % Rising edge
                markers(ch, max(1, index-pulsegen.mkraddwidth+1):index) = 1;
            else % Falling edge
                markers(ch, index+1:min(newlength, index+pulsegen.mkraddwidth)) = 1;
            end
        end
        % Shift marker by mkroffset
        if offset(ch) >= 0
            markers(ch,:) = [zeros(1, offset(ch)), ...
                             markers(ch, 1:end-offset(ch))];
        else
            markers(ch,:) = [markers(ch, 1-offset(ch):end), ...
                             zeros(1, -offset(ch))];
        end
        markers(ch,:) = uint8(markers(ch,:)*2^6);
        
    end
    % Update markers according to the original time axis
    pulsegen.marker1 = interp1(taxis, double(markers(1,:) ~= 0), pulsegen.timeaxis);
    pulsegen.marker2 = interp1(taxis, double(markers(2,:) ~= 0), pulsegen.timeaxis);
    
    % Generate waveforms
    pulsegen.GenerateRaw(waveforms, markers);
end