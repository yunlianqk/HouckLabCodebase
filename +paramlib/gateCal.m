classdef gateCal < handle
    % Gate calibrations object.
    % holds all of the calibrations for gates, gets updated by calibration
    % routines.
    
    properties
        % generic calibration properties
        sigma = 25e-9; % gaussian width in seconds
        cutoff = 100e-9; % force pulse tail to zero. this is the total time the pulse is nonzero in seconds
        buffer = 4e-9; % extra time beyond the cutoff to separate gates.  this is the total buffer, so half before and half after.
        qubitFreq=4e9;
        cavityFreq=10e9;
        % gate specific properties
        X90Amplitude = .5;
        X90DragAmplitude = 0;
        Xm90Amplitude = .5;
        Xm90DragAmplitude = 0;
        X180Amplitude = 1;
        X180DragAmplitude = 0;
        Y90Amplitude = .5;
        Y90DragAmplitude = 0;
        Ym90Amplitude = .5;
        Ym90DragAmplitude = 0;
        Y180Amplitude = 1;
        Y180DragAmplitude = 0;
    end
    
    properties (SetAccess = private)
        % gate objects.  Update these by changing the above
        % properties and then running updateGates method
        Identity;
        X90;
        Xm90;
        X180;
        Y90;
        Ym90;
        Y180;
    end
    
    methods
        function obj = gateCal()
            % constructor just calls the updateGates method
            obj.updateGates();
        end
        
        function obj=updateGates(obj)
            % uses gateCal property values to regenerate all of the gate objects
            sigma=obj.sigma;
            cutoff=obj.cutoff;
            buffer=obj.buffer;
            % generate standard gates
            obj.Identity=pulselib.gaussianWithDrag('Identity',0,0,0,0,sigma,cutoff,buffer);
            obj.X90=pulselib.gaussianWithDrag('X90',0,pi/2,obj.X90Amplitude,obj.X90DragAmplitude,sigma,cutoff,buffer);
            obj.Xm90=pulselib.gaussianWithDrag('Xm90',0,-pi/2,-obj.Xm90Amplitude,obj.Xm90DragAmplitude,sigma,cutoff,buffer);
            obj.X180=pulselib.gaussianWithDrag('X180',0,pi,obj.X180Amplitude,obj.X180DragAmplitude,sigma,cutoff,buffer);
            obj.Y90=pulselib.gaussianWithDrag('Y90',pi/2,pi/2,obj.Y90Amplitude,obj.Y90DragAmplitude,sigma,cutoff,buffer);
            obj.Ym90=pulselib.gaussianWithDrag('Ym90',pi/2,-pi/2,-obj.Ym90Amplitude,obj.Ym90DragAmplitude,sigma,cutoff,buffer);
            obj.Y180=pulselib.gaussianWithDrag('Y180',pi/2,pi,obj.Y180Amplitude,obj.Y180DragAmplitude,sigma,cutoff,buffer);
        end
    end
end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    
        