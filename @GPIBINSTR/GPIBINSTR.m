classdef GPIBINSTR < handle
    % A superclass for GPIB instrument that other classes can inherit.
    % Contains properties and methods that are common to all GPIB
    % instruments.
    
    properties
        address;    % GPIB address
        instrhandle;    % GPIB oject to communicate with instrument
    end
    
    methods
        function self = GPIBINSTR(address)
            %  Open instrument
            
            % If already opened, do nothing
            self.instrhandle = instrfind('Name', ['GPIB0-', num2str(address)], ...
                                         'Status', 'open');
            % If not opened, open it
            if isempty(self.instrhandle)
                self.instrhandle = gpib('ni', 0, address);
                fopen(self.instrhandle);
            end
            self.address = address;
        end
        
        function Finalize(self)
            % Close instrhandle
            
            if strcmp(self.instrhandle.Status, 'open')
                fclose(self.instrhandle);
            end
        end
    end
    
end

