classdef pulseCal
    % Pulse calibrations object. Holds calibrations for gates, measurement 
    % pulse, and acquisition window, gets updated by calibration routines.
    % NOTE: pulseCal objects are VALUE objects not HANDLE objects
    % NOTE: pulseCal has methods to generate a new pulse object on request,
    % so that in an experiment altering the pulses (HANDLE objects) does
    % not corrupt the calibration properties.
    
    properties
        % generic qubit pulse properties
        qubitFreq = 7.508e9;
        specPower = -50;
        sigma = 25e-9; % gaussian width in seconds
        cutoff = 100e-9; % force pulse tail to zero. this is the total time the pulse is nonzero in seconds
        buffer = 4e-9; % extra time beyond the cutoff to separate gates.  this is the total buffer, so half before and half after.
        % measurement pulse properties
        cavityFreq = 5.81015e9;
        cavityAmplitude = 0.1;
        rfPower = -60;
        intFreq = 0;
        loPower = 11;
        loAmplitude = 1;
        measDuration = 10e-6; % length of measurement pulse
        % waveform properties
        startBuffer = 5e-6; % delay after start before qubit pulses can occur
        measBuffer = 10e-9; % delay btw final qubit pulse and measurement pulse
        endBuffer = 5e-6; % buffer after measurement pulse
		% awg properties
        samplingRate = 32e9;
		fullscale = 1.0;
        % acquisition properties
        integrationStartIndex = 1; % start point for integration of acquisition card data
        integrationStopIndex = 4000; % stoppoint for integration of acquisition card data
        cardDelayOffset = 0.0e-6; % time delay AFTER measurement pulse to start acquisition
        % USAGE: cardparams.delaytime = experimentObject.measStartTime + pulseCal.cardDelayOffset;
        cardAvg = 30000;
        % gate specific properties
        X90Amplitude = .5;
        X90DragAmplitude = 0;
        Xm90Amplitude = .5;
        Xm90DragAmplitude = 0;
        X180Amplitude = 1;
        X180DragAmplitude = 0;
        Xm180Amplitude = 1;
        Xm180DragAmplitude = 0;
        Y90Amplitude = .5;
        Y90DragAmplitude = 0;
        Ym90Amplitude = .5;
        Ym90DragAmplitude = 0;
        Y180Amplitude = 1;
        Y180DragAmplitude = 0;
        Ym180Amplitude = 1;
        Ym180DragAmplitude = 0;
        % rectangular pulse with gaussian tail for cavity displacements
        rectPulseDuration = 1e-6;
        rectPulseAmp = 1.0;
        rectPulseSigma = 100e-9;
        X90Azimuth = 0;
        X180Azimuth = 0;
        Y90Azimuth = pi/2;
        Y180Azimuth = pi/2;
        Xm90Azimuth = pi;
        Xm180Azimuth = pi;
        Ym90Azimuth = -pi/2;
        Ym180Azimuth = -pi/2;
    end

    methods
        % methods to generate each type of pulse
        function pulseObj = Delay(obj,delay)
            pulseObj = pulselib.singleGate('Identity');
            pulseObj.sigma = obj.sigma;
            pulseObj.cutoff = delay;
            pulseObj.buffer = 0;
        end
        function pulseObj = Identity(obj)
            pulseObj = pulselib.singleGate('Identity');
            pulseObj.sigma = obj.sigma;
            pulseObj.cutoff = obj.cutoff;
            pulseObj.buffer = obj.buffer;
        end
        function pulseObj = X90(obj)
            pulseObj = pulselib.singleGate('X90');
            pulseObj.sigma = obj.sigma;
            pulseObj.cutoff = obj.cutoff;
            pulseObj.buffer = obj.buffer;
            pulseObj.amplitude = obj.X90Amplitude;
            pulseObj.dragAmplitude = obj.X90DragAmplitude;
            pulseObj.azimuth = obj.X90Azimuth;
        end
        function pulseObj = Xm90(obj)
            pulseObj = pulselib.singleGate('Xm90');
            pulseObj.sigma = obj.sigma;
            pulseObj.cutoff = obj.cutoff;
            pulseObj.buffer = obj.buffer;
            pulseObj.amplitude = obj.Xm90Amplitude;
            pulseObj.dragAmplitude = obj.Xm90DragAmplitude;
            pulseObj.azimuth = obj.Xm90Azimuth;
        end
        function pulseObj = X180(obj)
            pulseObj = pulselib.singleGate('X180');
            pulseObj.sigma = obj.sigma;
            pulseObj.cutoff = obj.cutoff;
            pulseObj.buffer = obj.buffer;
            pulseObj.amplitude = obj.X180Amplitude;
            pulseObj.dragAmplitude = obj.X180DragAmplitude;
            pulseObj.azimuth = obj.X180Azimuth;
        end
        function pulseObj = Xm180(obj)
            pulseObj = pulselib.singleGate('Xm180');
            pulseObj.sigma = obj.sigma;
            pulseObj.cutoff = obj.cutoff;
            pulseObj.buffer = obj.buffer;
            pulseObj.amplitude = obj.Xm180Amplitude;
            pulseObj.dragAmplitude = obj.Xm180DragAmplitude;
            pulseObj.azimuth = obj.Xm180Azimuth;
        end
        function pulseObj = Y90(obj)
            pulseObj = pulselib.singleGate('Y90');
            pulseObj.sigma = obj.sigma;
            pulseObj.cutoff = obj.cutoff;
            pulseObj.buffer = obj.buffer;
            pulseObj.amplitude = obj.Y90Amplitude;
            pulseObj.dragAmplitude = obj.Y90DragAmplitude;
            pulseObj.azimuth = obj.Y90Azimuth;
        end
        function pulseObj = Ym90(obj)
            pulseObj = pulselib.singleGate('Ym90');
            pulseObj.sigma = obj.sigma;
            pulseObj.cutoff = obj.cutoff;
            pulseObj.buffer = obj.buffer;
            pulseObj.amplitude = obj.Ym90Amplitude;
            pulseObj.dragAmplitude = obj.Ym90DragAmplitude;
            pulseObj.azimuth = obj.Ym90Azimuth;
        end
        function pulseObj = Y180(obj)
            pulseObj = pulselib.singleGate('Y180');
            pulseObj.sigma = obj.sigma;
            pulseObj.cutoff = obj.cutoff;
            pulseObj.buffer = obj.buffer;
            pulseObj.amplitude = obj.Y180Amplitude;
            pulseObj.dragAmplitude = obj.Y180DragAmplitude;
            pulseObj.azimuth = obj.Y180Azimuth;
        end
        function pulseObj = Ym180(obj)
            pulseObj = pulselib.singleGate('Ym180');
            pulseObj.sigma = obj.sigma;
            pulseObj.cutoff = obj.cutoff;
            pulseObj.buffer = obj.buffer;
            pulseObj.amplitude = obj.Ym180Amplitude;
            pulseObj.dragAmplitude = obj.Ym180DragAmplitude;
            pulseObj.azimuth = obj.Ym180Azimuth;
        end
        function pulseObj = measurement(obj)
            pulseObj = pulselib.measPulse(obj.measDuration,obj.cavityAmplitude);
            pulseObj.cutoff = 4*pulseObj.sigma;
            pulseObj.buffer = obj.buffer;
        end
        function pulseObj = rectPulse(obj)
            pulseObj = pulselib.measPulse(obj.rectPulseDuration,obj.rectPulseAmp);
            pulseObj.sigma = obj.rectPulseSigma;
            pulseObj.cutoff = 4*pulseObj.sigma;
            pulseObj.buffer = obj.buffer;
        end
        
        function s = toStruct(obj)
            s = funclib.obj2struct(obj);
        end
    end
end