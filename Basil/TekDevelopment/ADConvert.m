function DigiWform = ADConvert(Wform,WformType)

    max_level = 2^14-1;

    if strcmp(WformType,'ch')
        dig = floor(Wform*max_level/254);
        binblock = zeros(1,2*length(dig));
        binblock(1:2:end) = bitand(dig, 255);
        binblock(2:2:end) = bitshift(dig,-8);
        numbytes = num2str(length(binblock));
        DigiWform.Header = ['#' num2str(length(numbytes)) numbytes];
        DigiWform.Data = binblock;

    elseif strcmp(WformType, 'ch_marker')
        marker1 = varargin{1};
        marker2 = varargin{2};
        marker = marker1*bin2dec('01000000') + marker2*bin2dec('10000000');
        numbytes = num2str(length(marker));
        DigiWform.Header = ['#' num2str(length(numbytes)) numbytes];
        DigiWform.Data = marker;
    end
end


