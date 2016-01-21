function SetFreq(gen, varargin)
% Set frequency
    if isempty(varargin)
        freq = gen.frequency;
    else
        freq = varargin{1};
    end
    fprintf(gen.instrhandle, ['FREQuency ', num2str(freq)]);
    gen.frequency = freq;
end