function SetPower(gen, varargin)
% Set power
    if isempty(varargin)
        pow = gen.power;
    else
        pow = varargin{1};
    end
    fprintf(gen.instrhandle, ['POWer ', num2str(pow)]);
    gen.power = pow;
end