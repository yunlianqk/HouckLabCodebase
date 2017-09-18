classdef Tek5014AWG < GPIBINSTR
    % Contains paramaters and methods for Tek5014AWG
    
    properties
        %         samplingrate; % Default = 1.25 GHz, can be reduced by factors of 2^n, 0<=n<=10
        %         timeaxis = (0:255)*0.8e-9; % Time axis
        %         waveform1 = zeros(1, 256); % Waveforms
        %         waveform2 = zeros(1, 256);
        %         marker1 = zeros(1, 256); % Markers
        %         marker2 = zeros(1, 256);
        %         marker3 = zeros(1, 256);
        %         marker4 = zeros(1, 256);
    end
    methods
        function Tek5014AWG = Tek5014AWG(address)
            Tek5014AWG = Tek5014AWG@GPIBINSTR(address);
        end
        
        function ADConvert()
            
        end
            %         function set.samplingrate(self, samplerate)
            %             SetSampleRate(self, samplerate);
            %         end
            %
            %         function samplingrate = get.samplingrate(self)
            %             samplingrate = GetSampleRate(self);
            %         end
            
            %         SetSampleRate(self, samplerate); % Set sampling rate
            %         samplingrate = GetSampleRate(self); % Get sampling rate
        
    end
end
