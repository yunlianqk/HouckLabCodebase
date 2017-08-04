classdef N5183BMXG < E8267DGenerator
% Contains paramaters and methods for N5183B analogue generator

% The SCPI interface is identical to that of E8267D
% So we inherit everything from there
    methods
        function self = N5183BMXG(address)
            self = self@E8267DGenerator(address);
        end
    end
end

