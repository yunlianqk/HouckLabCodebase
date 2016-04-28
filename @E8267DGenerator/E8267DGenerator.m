classdef E8267DGenerator < GPIBINSTR
% Contains paramaters and methods for E8267D vector generator

    properties (Dependent)
        frequency;
        power;
    end
    
    methods
        function gen = E8267DGenerator(address)
            gen = gen@GPIBINSTR(address);
            display([class(gen), ' object created.']);
        end
        function set.frequency(gen, freq)
            SetFreq(gen, freq);
        end
        function set.power(gen, power)
            SetPower(gen, power);
        end
        function freq = get.frequency(gen)
            freq = GetFreq(gen);
        end
        function power = get.power(gen)
            power = GetPower(gen);
        end
        
        % Declaration of all other methods
        % Each method is defined in a separate file        
        SetFreq(gen, freq);
        SetPower(gen, power);
        
        freq = GetFreq(gen);
        power = GetPower(gen);
        
        PowerOn(gen);
        PowerOff(gen);
        
        ModOn(gen);
        ModOff(gen);
    end
end
