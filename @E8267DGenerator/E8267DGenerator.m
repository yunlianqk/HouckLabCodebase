classdef E8267DGenerator < GPIBINSTR
% Contains paramaters and methods for E8267D vector generator

    properties
        freq;
        power;
        phase;
        output;
        modulation;
        iq;
        pulse;
        alc;
    end
    methods
        function gen = E8267DGenerator(address)
            gen = gen@GPIBINSTR(address);
        end
        function set.freq(gen, freq)
            SetFreq(gen, freq);
        end
        function set.power(gen, power)
            SetPower(gen, power);
        end
        function set.phase(gen, phase)
            SetPhase(gen, phase);
        end
        function set.output(gen, output)
            if output
                gen.PowerOn();
            else
                gen.PowerOff();
            end
        end
        function set.modulation(gen, mod)
            if mod
                fprintf(gen.instrhandle, 'OUTPut:MODulation 1');
            else
                fprintf(gen.instrhandle, 'OUTPut:MODulation 0');
            end
        end
        function set.iq(gen, iq)
            if strfind(gen.Info(), 'E8267D')
            % Only E8267D has wideband I/Q modulation
                if iq
                    fprintf(gen.instrhandle, 'WDM:STATe 1');
                else
                    fprintf(gen.instrhandle, 'WDM:STATe 0');
                end
            end
        end
        function set.pulse(gen, pulse)
            if pulse
                fprintf(gen.instrhandle, 'PULM:STATe 1');
            else
                fprintf(gen.instrhandle, 'PULM:STATe 0');
            end
        end
        function set.alc(gen, alc)
            if alc
                fprintf(gen.instrhandle, 'POWer:ALC 1');
            else
                fprintf(gen.instrhandle, 'POWer:ALC 0');
            end
        end
        
        function freq = get.freq(gen)
            freq = GetFreq(gen);
        end
        function power = get.power(gen)
            power = GetPower(gen);
        end
        function phase = get.phase(gen)
            phase = GetPhase(gen);
        end
        function output = get.output(gen)
            fprintf(gen.instrhandle, 'OUTPut?');
            output = fscanf(gen.instrhandle, '%f');
        end
        function mod = get.modulation(gen)
            fprintf(gen.instrhandle, 'OUTPut:MODulation?');
            mod = fscanf(gen.instrhandle, '%f');
        end
        function iq = get.iq(gen)
            iq = 0;
            if strfind(gen.Info(), 'E8267D')
            % Only E8267D has wideband I/Q modulation
                fprintf(gen.instrhandle, 'WDM:STATe?');
                iq = fscanf(gen.instrhandle, '%f');
            end
        end
        function pulse = get.pulse(gen)
            fprintf(gen.instrhandle, 'PULM:STATe?');
            pulse = fscanf(gen.instrhandle, '%f');
        end
        function alc = get.alc(gen)
            fprintf(gen.instrhandle, 'POWer:ALC?');
            alc = fscanf(gen.instrhandle, '%f');
        end
        % Declaration of all other methods
        % Each method is defined in a separate file        
        SetFreq(gen, freq);
        SetPower(gen, power);
        SetPhase(gen, phase);
        
        freq = GetFreq(gen);
        power = GetPower(gen);
        phase = GetPhase(gen);
        
        PowerOn(gen);
        PowerOff(gen);
        
        ModOn(gen);
        ModOff(gen);
        
        ShowError(gen);
    end
end
