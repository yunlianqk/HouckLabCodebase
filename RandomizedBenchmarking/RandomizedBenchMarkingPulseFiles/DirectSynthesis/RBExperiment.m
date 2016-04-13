classdef RBExperiment < handle
    %Randomized Benchmarking Experiment object for generating waveforms to
    %be sent to the awg.
    
    properties
        % sequence properties
%         sequenceList = 1:10; % list containing number of clifford gates in each subsequence
        sequenceList = 4; % list containing number of clifford gates in each subsequence
        primitiveLists; % cell array containing lists of the gate primitives for each subsequence
        
        % general waveform properties
        samplingRate = 1.25e9; % sampling rate to generate baseband signals - 1.25 GS/s works with M9330AWG 
        startDelay = .1e-6; % delay after start of waveform before pulses start   
        endDelay = .1e-6; % delay after end of measurement pulse to end of waveform
        
        % qubit pulse properties
        gateSigma = 10e-9; % gaussian standard deviation
%         gateCutoff = 4*gateSigma; % total time gate is nonzero, centered around pulse peak
        gateBuffer = 10e-9; % extra time between gates, 0 means next pulse starts as soon as previous one gets cut off
        
        % measurement pulse properties
        % ADC card trigger
        % gating pulse properties
    end
    
%     properties (Dependent)
    
    methods
        function generatePrimitives(obj) % use provided IBM code to generate cell array of lists
            primitiveLists = CliffordGroup(obj.sequenceList);
            size(primitiveLists)
            obj.primitiveLists = primitiveLists;
            obj.primitiveLists{1}
        end
        
        % calculate peak times for the pulses in a subsequence waveform set
        % generate a subsequence waveform 'set' (given a subsequence of primitives generate all waveforms)
        % visualize subsequence waveform 'set'
        
        
        
        
        
        
    end
end
       