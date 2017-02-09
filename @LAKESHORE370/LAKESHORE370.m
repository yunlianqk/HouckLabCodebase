classdef LAKESHORE370 < GPIBINSTR
% Contains paramaters and methods for LakeShore 370 AC resistance bridge

    properties (SetAccess = private)
        channels;
        temperature;
    end
    methods
        function self = LAKESHORE370(address)
            self = self@GPIBINSTR(address);
        end
        function channels = get.channels(self)
            channels = GetChannels(self);
        end
        function temp = get.temperature(self)
            temp = GetTemp(self);
        end
        
        function channels = GetChannels(self)
           channels = [];
           for ch = 1:16
               tempstr = query(self.instrhandle, sprintf('INSET? %d', ch));
               isactive = str2double(tempstr(1));
               if isactive
                   channels = [channels, ch];
               end
           end
        end
        function temp = GetTemp(self)
            chlist = self.GetChannels();
            temp = zeros(1, length(chlist));
            ii = 1;
            for ch = chlist
                temp(ii) = str2double(query(self.instrhandle, sprintf('RDGK? %d', ch)));
                ii = ii + 1;
            end
        end
    end
end
