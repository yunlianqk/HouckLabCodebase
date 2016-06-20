classdef PNAXAnalyzer < GPIBINSTR
% Contains paramaters and methods for PNA-X Network Analyzer

    properties
        params;
    end
    properties (Access = private)
        timeout = 10;
    end
    methods
        function pnax = PNAXAnalyzer(address)
            pnax = pnax@GPIBINSTR(address);
        end
        function set.params(pnax, transparams)
            SetParams(pnax, transparams);
        end
        function params = get.params(pnax)
            params = GetParams(pnax);
        end
        % Declaration of all other methods
        % Each method is defined in a separate file
        SetParams(pnax, params);
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
        
        TrigContinuous(pnax, varargin);
        TrigHold(pnax, varargin);
        TrigSingle(pnax, varargin);
        TrigHoldAll(pnax);
        
        AvgOn(pnax, varagin);
        AvgOff(pnax, varagin);
        AvgClear(pnax, varagin);
        
        AutoScale(pnax, varagin);
        AutoScaleAll(pnax);
        
        Reset(pnax);
    end
    methods (Access = protected)
        iscorrect = CheckParams(pnax, params);
        isspec = IsSpec(pnax, channel);
        ispswepp = IsPsweep(pnax, channel);
        measname = MeasName(pnax, channel, trace, meastype);
        meastype = GetMeasType(pnax, meas);

        SetTransParams(pnax, transparams);
        UpdateTransParams(pnax, oldparams, newparams);
        transparams = GetTransParams(pnax);
        
        SetSpecParams(pnax, specparams);
        UpdateSpecParams(pnax, oldparams, newparams);
        specparams = GetSpecParams(pnax);
        
        SetPsweepParams(pnax, psweepparams);
        UpdatePsweepParams(pnax, oldparams, newparams);
        psweepparams = GetPsweepParams(pnax);
    end
end