classdef AWG33250A < GPIBINSTR
% Contains paramaters and methods for 33250A AWG

    properties (Dependent)
        waveform;
        frequency;
        vpp;
        offset;
        dutycycle;
    end
    
    methods
        function triggen = AWG33250A(address)
            triggen = triggen@GPIBINSTR(address);
        end
        function set.waveform(triggen, waveform)
            SetWaveform(triggen, waveform);
        end
        function set.frequency(triggen, frequency)
            SetFreq(triggen, frequency);
        end
        function set.vpp(triggen, vpp)
            SetAmp(triggen, vpp);
        end
        function set.offset(triggen, offset)
            SetOffset(triggen, offset);
        end
        function set.dutycycle(triggen, dutycycle)
            SetDutyCycle(triggen, dutycycle);
        end
        
        function waveform = get.waveform(triggen)
            waveform = GetWaveform(triggen);
        end
        function frequency = get.frequency(triggen)
            frequency = GetFreq(triggen);
        end
        function vpp = get.vpp(triggen)
            vpp = GetAmp(triggen);
        end
        function offset = get.offset(triggen)
            offset = GetOffset(triggen);
        end
        function dutycycle = get.dutycycle(triggen)
            dutycycle = GetDutyCycle(triggen);
        end
        
        % Declaration of all methods
        % Each method is defined in a separate file
        SetWaveform(triggen, waveform);
        SetFreq(triggen, frequency);
        SetAmp(triggen, vpp);
        SetOffset(triggen, offset);
        SetDutyCycle(triggen, dutycycle);
        
        waveform = GetWaveform(triggen);
        frequency = GetFreq(triggen);
        vpp = GetAmp(triggen);
        offset = GetOffset(triggen);
        dutycycle = GetDutyCycle(triggen);
        
        PowerOn(triggen);
        PowerOff(triggen);
    end
end