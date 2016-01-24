function SetPeriod(triggen, varargin)
% Set period
    if (~isempty(varargin))
        triggen.period = varargin{1};
    end
    triggen.SetParams();
end