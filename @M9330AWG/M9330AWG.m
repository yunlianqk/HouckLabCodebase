classdef M9330AWG < handle
% Contains paramaters and methods for M9930A AWG

    properties (SetAccess = private, GetAccess = public)
        address;    % PXI address
        instrhandle;% Handle for the instrument
        marker1;    % Marker 1
        marker2;    % Marker 2
        samplingrate;   % Default = 1.25 GHz, can be reduced by factors of 2^n
    end
    properties (Access = public)
        waveform1 = zeros(1,256);	% Minimum length is 128
        waveform2 = zeros(1,256);
        timeaxis = (0:255)*0.8e-9;
        mkr1offset = 0;
        mkr2offset = 0;
        mkraddwidth = 32;
    end
    properties (Constant, Access = private)
        CH1MAXAMP = 32767;  % Maximum value = 32767
        CH2MAXAMP = 32767;  % Maximum value = 32767
        TRIGINPORT = 1;	% Port number for trigger input
        MKR1PORT = 2;	% Port number for marker 1 output
        MKR2PORT = 4;	% Port number for marker 2 output
        TRIGOUTPORT = 1;	% Port number for trigger output
        OUTPUTCONFIG = 2;	% 0 = differential, gain can be 0.340 to 0.500
                           	% 1 = single-ended, gain can be 0.170 to 0.250 
                         	% 2 = amplified (single-ended), gain can be 0.340 to 0.500
    end
    
    methods (Access = public)
        function pulsegen = M9330AWG(address)
        % Open instrhandle
            sysinfo = mexext();
            if strcmp(sysinfo(end-1:end), '64')
                error('AWG M9330A only works with 32-bit MATLAB');
            end
            pulsegen.address = address;
            initoptions = 'QueryInstrStatus=true,DriverSetup=DDS=false';
            pulsegen.instrhandle = instrument.driver.AgM933x();
            pulsegen.instrhandle.Initialize(pulsegen.address, true, true, initoptions);          
            pulsegen.samplingrate = pulsegen.instrhandle.DeviceSpecific.Arbitrary.SampleRate;
        end
        
        % Declaration of all methods
        % Each method is defined in a separate file               
        Finalize(pulsegen); % Close instrhandle
        Generate(pulsegen); % Load waveforms, create markers and generate output
        GenerateRaw(pulsegen, waveforms, markers); % Low level method for waveform generation
    end
end
