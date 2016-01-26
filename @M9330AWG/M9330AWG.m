classdef M9330AWG < handle
% Contains paramaters and methods for M9930A AWG
% To generate waveforms, fill the fields waveform1, waveform2 and timeaxis.
% Running SetParams() will set up the device and generate the waveforms.
% The three fields should have the same length, but does not need to
% be multiple of 8.
% The amplitude of the waveforms should be in the range between -1 and +1.
% If max(abs(waveform)) > 1, the program will normalize it to 1. 
% timeaxis is in unit of seconds. The sampling rate does not need to be the
% sampling rate of the device. The program will automatically interpolate
% the timeaxis and waveforms according to the real sampling rate and
% increase the length to multiple of 8.
% Markers will be generated automatically wherever the waveform is non-zeros.
% Use mkr1offset, mkr2offset and mkraddwidth to modify markers. See the pic
% in the folder for their meanings.
% When necessary, GenerateRaw() method can be used to directly generate
% waveforms using the rawdata type. Consult the manual for specifications
% for rawdata waveform.

    properties (SetAccess = private, GetAccess = public)
        address;    % GPIB address
        instrhandle;    % gpib object for the instrument
        marker1;    % Auto generated marker 1
        marker2;    % Auto genearted marker 2
        samplingrate;   % default = 1.25 GHz, can be reduced by factors of exactly two

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
        CH1MAXAMP = 32000;  % Range: -32768 to + 32767
        CH2MAXAMP = 8300;   % Calibrated so that generator output is the same for CW/pulsed
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
        SetParams(pulsegen);    % Set up waveforms and markers
        GenerateRaw(pulsegen, waveforms, markers);	% Low level code for waveform generation
    end
end