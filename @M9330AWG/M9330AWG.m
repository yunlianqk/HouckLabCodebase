classdef M9330AWG < handle
% Contains paramaters and methods for M9930A AWG

    properties (SetAccess = private, GetAccess = public)
        address;    % GPIB address
        instrhandle;    % gpib object for the instrument
        marker1;    % Auto generated marker 1
        marker2;    % Auto genearted marker 2
        ch1maxamp = 32000;  % Range: -32768 to + 32767
        ch2maxamp = 10000;
%         ch1maxamp = 2^15;
%         ch2maxamp = 2^15;
        mkrthreshold = 2^-15;   % Use marker for waveform values greater than this threshold
        triggerinport = 1;      % Port number for trigger input
        marker1port = 2;    % Port number for marker 1 output
        marker2port = 4;    % Port number for marker 2 output
        triggeroutport = 1; % Port number for trigger output
        outputconfiguration = 2;	% 0 = differential, gain can be 0.340 to 0.500
                                    % 1 = single-ended, gain can be 0.170 to 0.250 
                                    % 2 = amplified (single-ended), gain can be 0.340 to 0.500
        samplingrate;   % default = 1.25 GHz, can be reduced by factors of exactly two

    end
    properties (Access = public)
        waveform1 = [ones(1,128), zeros(1,128)];    % Minimum length of 128 samples
        waveform2 = [sin(2*pi*(0:127)/128), zeros(1,128)];
        timeaxis = (0:255)*0.8e-9;
        mkr1offset = 0;
        mkr2offset = 0;
        mkraddwidth = 32;
    end
    
    methods
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
        SetParams(pulsegen);    % Set up waveforms and markers
    end
    methods (Access = protected)
        Generate(pulsegen, waveforms, markers);	% Low level code for waveform generation
    end
end