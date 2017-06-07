classdef E8267DGenerator < GPIBINSTR
% Contains paramaters and methods for E8267D vector generator

    properties
        freq;  % Frequency in Hz
        power;  % Power in dBm
        phase;  % Phase in radian
        output;  % Output on/off
        modulation;  % Modulation on/off
        iq;  % IQ modulation on/off
        iqadjust;  % IQ adjustment on/off
        ioffset;  % I offset in volts
        qoffset;  % Q offset in volts
        pulse;  % Pulse modulation on/off
        alc;  % ALC on/off
    end
    methods
        function self = E8267DGenerator(address)
            self = self@GPIBINSTR(address);
        end
        function set.freq(self, freq)
            SetFreq(self, freq);
        end
        function set.power(self, power)
            SetPower(self, power);
        end
        function set.phase(self, phase)
            SetPhase(self, phase);
        end
        function set.output(self, state)
            if state
                self.PowerOn();
            else
                self.PowerOff();
            end
        end
        function set.modulation(self, state)
            if state
                fprintf(self.instrhandle, 'OUTPut:MODulation 1');
            else
                fprintf(self.instrhandle, 'OUTPut:MODulation 0');
            end
        end
        function set.iq(self, state)
            if strfind(self.Info(), 'E8267D')
            % Only E8267D has wideband I/Q modulation
                if state
                    fprintf(self.instrhandle, 'WDM:STATe 1');
                else
                    fprintf(self.instrhandle, 'WDM:STATe 0');
                end
            end
        end
        function set.iqadjust(self, state)
            if strfind(self.Info(), 'E8267D')
            % Only E8267D has wideband I/Q modulation
                if state
                    fprintf(self.instrhandle, 'WDM:IQADjustment 1');
                else
                    fprintf(self.instrhandle, 'WDM:IQADjustment 0');
                end
            end
        end
        function set.ioffset(self, offset)
            if strfind(self.Info(), 'E8267D')
            % Only E8267D has wideband I/Q modulation
                fprintf(self.instrhandle, 'WDM:IQADjustment:IOFFset %f', offset);
            end
        end
        function set.qoffset(self, offset)
            if strfind(self.Info(), 'E8267D')
            % Only E8267D has wideband I/Q modulation
                fprintf(self.instrhandle, 'WDM:IQADjustment:QOFFset %f', offset);
            end
        end
        function set.pulse(self, state)
            if state
                fprintf(self.instrhandle, 'PULM:STATe 1');
            else
                fprintf(self.instrhandle, 'PULM:STATe 0');
            end
        end
        function set.alc(self, state)
            if state
                fprintf(self.instrhandle, 'POWer:ALC 1');
            else
                fprintf(self.instrhandle, 'POWer:ALC 0');
            end
        end
        
        function freq = get.freq(self)
            freq = GetFreq(self);
        end
        function power = get.power(self)
            power = GetPower(self);
        end
        function phase = get.phase(self)
            phase = GetPhase(self);
        end
        function state = get.output(self)
            fprintf(self.instrhandle, 'OUTPut?');
            state = fscanf(self.instrhandle, '%d');
        end
        function state = get.modulation(self)
            fprintf(self.instrhandle, 'OUTPut:MODulation?');
            state = fscanf(self.instrhandle, '%d');
        end
        function state = get.iq(self)
            state = 0;
            if strfind(self.Info(), 'E8267D')
            % Only E8267D has wideband I/Q modulation
                fprintf(self.instrhandle, 'WDM:STATe?');
                state = fscanf(self.instrhandle, '%d');
            end
        end
        function state = get.iqadjust(self)
            state = 0;
            if strfind(self.Info(), 'E8267D')
            % Only E8267D has wideband I/Q modulation
                fprintf(self.instrhandle, 'WDM:IQADjustment?');
                state = fscanf(self.instrhandle, '%d');
            end
        end
        function offset = get.ioffset(self)
            offset = 0;
            if strfind(self.Info(), 'E8267D')
            % Only E8267D has wideband I/Q modulation
                fprintf(self.instrhandle, 'WDM:IQADjustment:IOFFset?');
                offset = fscanf(self.instrhandle, '%f');
            end
        end
        function offset = get.qoffset(self)
            offset = 0;
            if strfind(self.Info(), 'E8267D')
            % Only E8267D has wideband I/Q modulation
                fprintf(self.instrhandle, 'WDM:IQADjustment:QOFFset?');
                offset = fscanf(self.instrhandle, '%f');
            end
        end
        function state = get.pulse(self)
            fprintf(self.instrhandle, 'PULM:STATe?');
            state = fscanf(self.instrhandle, '%d');
        end
        function state = get.alc(self)
            fprintf(self.instrhandle, 'POWer:ALC?');
            state = fscanf(self.instrhandle, '%d');
        end
        % Declaration of all other methods
        % Each method is defined in a separate file        
        SetFreq(self, freq);
        SetPower(self, power);
        SetPhase(self, phase);
        
        freq = GetFreq(self);
        power = GetPower(self);
        phase = GetPhase(self);
        
        PowerOn(self);
        PowerOff(self);
        
        ModOn(self);
        ModOff(self);
        
        ShowError(self);
    end
end
