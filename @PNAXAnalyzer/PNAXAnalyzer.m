classdef PNAXAnalyzer < GPIBINSTR
% Contains paramaters and methods for PNA-X Network Analyzer

    properties (Dependent)
        transparams;
        specparams;
    end
    properties (Access = private)
        defaulttransparams = struct('start', 5e9, ...
                                    'stop', 6e9, ...
                                    'points', 1001, ...
                                    'power', -50, ...
                                    'averages', 1000, ...
                                    'ifbandwidth', 5e3, ...
                                    'channel', 1, ...
                                    'trace', 1, ...
                                    'meastype', 'S21', ...
                                    'format', 'MLOG');
        defaultspecparams = struct('start', 4e9, ...
                                   'stop', 5e9, ...
                                   'points', 1001, ...
                                   'power', -50, ...
                                   'averages', 1000, ...
                                   'ifbandwidth', 5e3, ...
                                   'cwfreq', 7e9, ...
                                   'cwpower', -50, ...
                                   'channel', 2, ...
                                   'trace', 3, ...
                                   'meastype', 'S21', ...
                                   'format', 'MLOG');
        timeout = 10;
    end
    methods
        function pnax = PNAXAnalyzer(address)
            pnax = pnax@GPIBINSTR(address);
        end
        function set.transparams(pnax, transparams)
            SetTransParams(pnax, transparams);
        end
        function transparams = get.transparams(pnax)
            transparams = GetParams(pnax);
        end
        function set.specparams(pnax, specparams)
            SetSpecParams(pnax, specparams);
        end
        function specparams = get.specparams(pnax)
            specparams = GetParams(pnax);
        end
        function transparams = GetTransParams(pnax)
            transparams = GetParams(pnax);
        end
        function specparams = GetSpecParams(pnax)
            specparams = GetParams(pnax);
        end
        % Declaration of all other methods
        % Each method is defined in a separate file
        SetTransParams(pnax, transparams);
        SetSpecParams(pnax, specparams);
        SetActiveChannel(pnax, channel);
        SetActiveTrace(pnax, trace);
        SetActiveMeas(pnax, meas);
        
        params = GetParams(pnax);
        chlist = GetChannelList(pnax);
        trlist = GetTraceList(pnax);
        measlist = GetMeasList(pnax, varargin);
        channel = GetActiveChannel(pnax);
        trace = GetActiveTrace(pnax);
        meas = GetActiveMeas(pnax);

        data = Read(pnax);
        xaxis = ReadAxis(pnax);
        data = ReadTrace(pnax, varargin);
        dataarray = ReadChannel(pnax, varargin);
        
        CreateMeas(pnax, channel, trace, meas, meastype);
        DeleteChannel(pnax, channel);
        DeleteMeas(pnax, channel, meas);
        DeleteTrace(pnax, trace);
        DeleteAll(pnax);
        
        PowerOn(pnax);
        PowerOff(pnax);
        
        TrigContinuous(pnax);
        TrigHold(pnax);
        TrigSingle(pnax);
        TrigHoldAll(pnax);
        
        AvgOn(pnax);
        AvgOff(pnax);
        AvgClear(pnax);
        
        AutoScale(pnax);
        AutoScaleAll(pnax);
        
        Reset(pnax);
    end
    methods (Access = protected)
        iscorrect = CheckParams(pnax, params);
        measname = MeasName(pnax, channel, trace, meastype);
        meastype = GetMeasType(pnax, meas);
    end
end