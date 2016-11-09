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
            success = 0;
            self.address = address;
            % Extract integer primary GPIB address from full address string
            instrID = sscanf(address, 'GPIB0::%d::0::INSTR');
            % Try finding the instrument using address
            self.instrhandle = instrfind('Name', ['VISA-GPIB0-', num2str(instrID), '-0'], ...
                                         'Status', 'open');
            % If closed, open it and attach handle to self
            if isempty(self.instrhandle)
                % Try different vendors
                vendorlist = {'ni', 'agilent'};
                for vendor = vendorlist
                    try
                        % Use 'visa' instead of 'gpib' to support both
                        % GPIB card and GPIB-USB adapter
                        self.instrhandle = visa(vendor{1}, address);
                        fopen(self.instrhandle);
                        success = 1;
                        break;
                    catch
                    end
                end
            % If already open, do nothing
            else
                success = 1;
            end
            if ~success
                error([class(self), ' object initialization failed. ', ...
                      'Address: ', address]);
            else
                display([class(self), ' object created.']);
            end
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

