function DigiWform = ADConvert(varargin)
 
max_level = 2^14-1;
 
 if nargin == 2 && strcmp(varargin{2},'ch')
    Wform = varargin{1};
    dig = floor(Wform*max_level/254);
    binblock = zeros(1,2*length(dig));
    binblock(1:2:end) = bitand(dig, 255);
    binblock(2:2:end) = bitshift(dig,-8);
    numbytes = num2str(length(binblock));
    DigiWform.Header = ['#' num2str(length(numbytes)) numbytes];
    DigiWform.Data = binblock;
      
    else if nargin == 3 && strcmp(varargin{3}, 'ch_marker')
      marker1 = varargin{1};
      marker2 = varargin{2};
      marker = marker1*bin2dec('01000000') + marker2*bin2dec('10000000');
      numbytes = num2str(length(marker));
      DigiWform.Header = ['#' num2str(length(numbytes)) numbytes];
      DigiWform.Data = marker;    
         end
  end
 
end

