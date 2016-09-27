classdef GPIBINSTR < handle
    % A superclass for GPIB instrument that other classes can inherit.
    % Contains properties and methods that are common to all GPIB
    % instruments.
    
    properties (SetAccess = private, GetAccess = public)
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
            display([class(self), ' object created.']);
        end
        
        function Finalize(self)
            % Close instrhandle            
            if strcmp(self.instrhandle.Status, 'open')
                fclose(self.instrhandle);
            end
            display([class(self), ' object finalized.']);
        end
        
        function SendCommand(self, command)
            % Send low-level command to instrument
            if strcmp(self.instrhandle.Status, 'open')
                fprintf(self.instrhandle, command);
            else
                display('Instrument is not open');
            end
        end
        
        function s = Info(self)
            % Display and return instrument info
            fprintf(self.instrhandle, '*IDN?');
            s = fscanf(self.instrhandle, '%s');
        end
        function Reset(self)
            % Reset instrument
            fprintf(self.instrhandle, '*RST');
        end
    end
    
end

