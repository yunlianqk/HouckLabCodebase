function iscorrect = CheckParams(~, params)
% Check the correctness of paramters
    
    iscorrect = 1;
    % Check params class
    if ~isa(params, 'paramlib.m9703a')
        display('Error: params needs to be ''paramlib.m9703a'' object');
        iscorrect = 0;
    end
    
    % Check sampling rate
    maxrate = 1.6e9;
    exponent = log2(maxrate/params.samplerate);
    if (floor(exponent) ~= ceil(exponent) || params.samplerate < 50e6)
        fprintf('Sampling rate must be %.2e/2^n (0<=n<=5)\n', maxrate);
        iscorrect = 0;
    end
    
    % Check number of averages and segments
    if params.segments*params.averages > 65536
        display('Error: segments*averages needs to be less than 65537');
        iscorrect = 0;
    end
    
    if params.segments*params.averages*params.samples > 2^27
        display('Warning: segments*averages*samples needs to be less than 2^27');
    end
    
    % Check full scale
    if ~ismember(params.fullscale, [1, 2])
        display('Error: fullscale needs to be 1 or 2');
        iscorrect = 0;
    end
    
    % Check offset
    if (abs(params.offset) > 2*params.fullscale)
        display('Error: abs(offset) needs to be less than 2*fullscale');
        iscorrect = 0;
    end
    
    % Check coupling mode
    if ~ismember(params.couplemode, {'AC', 'DC'})
        display('Error: couplemode needs to be ''AC''/''DC''');
    end
    
    %AKmod
%     % Check channel name
%     if (isempty(regexp(params.ChI, 'Channel[1-8]', 'once')) || ...
%         isempty(regexp(params.ChI, 'Channel[1-8]', 'once')))
%         display('Error: ChI and ChQ needs to be ''Channel1-8''');
%         iscorrect = 0;
%     end
    
    % Check trigger source
    if isempty(regexp(params.trigSource, '(Channel[1-8]|External[1-3])', 'once'))
        display('Error: trigSource needs to be ''External1-4'' or ''Channel1-8''');
        iscorrect = 0;
    end
end