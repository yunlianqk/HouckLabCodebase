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
            
            % If already opened, attach the handle to self
            self.instrhandle = instrfind('Name', ['GPIB0-', num2str(address)], ...
                                         'Status', 'open');
            % If not opened, open it and attach handle to self
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
                clrdevice(self.instrhandle);  % Clear input and output buffer
                fclose(self.instrhandle);
            end
            display([class(self), ' object finalized.']);
        end
        
        function SendCommand(self, command)
            % Send low-level command to instrument
            fprintf(self.instrhandle, command);
        end
        
        function s = GetReply(self)
            % Read data from instrument output buffer
            s = fscanf(self.instrhandle, '%s');
        end
        
        function s = Query(self, command)
            % Send low-level inquiry to instrument and get reply
            % Same as SendCommand + GetReply
            if ~ismember('?', command)
                % If command doesn't contain '?', throw warning
                if ~strcmp(input('command does not contain ''?''. Are you sure (y/N)? ', 's'), 'y')
                    return;
                end
            end
            s = query(self.instrhandle, command);
        end
        

        function s = Info(self)
            % Return instrument info
            fprintf(self.instrhandle, '*IDN?');
            s = fscanf(self.instrhandle, '%s');
        end
        function Reset(self)
            % Reset instrument
            fprintf(self.instrhandle, '*RST');
        end
    end
    
end

