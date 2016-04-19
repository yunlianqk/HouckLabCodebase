classdef RBExperiment < handle
    %Randomized Benchmarking Experiment object for generating waveforms to
    %be sent to the awg.
    
    properties
        primitives; % empty object array of primitive gates. populated in constructor
        cliffords; % empty object array of clifford gates
        gateParams; % struct of microwave gate pulse parametrs
        
        % sequence properties
%         sequenceList = 1:10; % list containing number of clifford gates in each subsequence
        sequenceList = 4; % list containing number of clifford gates in each subsequence
%         primitiveLists; % cell array containing lists of the gate primitives for each subsequence
        
        % general waveform properties
%         samplingRate = 1.25e9; % sampling rate to generate baseband signals - 1.25 GS/s works with M9330AWG 
%         startDelay = .1e-6; % delay after start of waveform before pulses start   
%         endDelay = .1e-6; % delay after end of measurement pulse to end of waveform
        
        % qubit pulse properties
%         gateSigma = 10e-9; % gaussian standard deviation
%         gateCutoff = 4*gateSigma; % total time gate is nonzero, centered around pulse peak
%         gateBuffer = 10e-9; % extra time between gates, 0 means next pulse starts as soon as previous one gets cut off
        
        % measurement pulse properties
        % ADC card trigger
        % gating pulse properties
    end
    
%     properties (Dependent)
    
    methods
        function obj=RBExperiment()% constructor
            obj.initPrimitives();
            obj.initCliffords();
        end
        
        function obj=initPrimitives(obj)
            % general pulse parameters
            sigma=10e-9; % gaussian width in seconds
            cutoff=4*sigma;  % force pulse tail to zero. this is the total time the pulse is nonzero in seconds
            buffer=10e-9; % extra time beyond the cutoff to separate gates.  this is the total buffer, so half before and half after.
            % generate primitives
            amplitude=1;
            dragAmplitude=.5;
            primitives(1)=gaussianWithDrag('Identity',0,0,0,0,sigma,cutoff,buffer);
            primitives(2)=gaussianWithDrag('X180',0,pi,amplitude,dragAmplitude,sigma,cutoff,buffer);
            primitives(3)=gaussianWithDrag('X90',0,pi/2,amplitude,dragAmplitude,sigma,cutoff,buffer);
            primitives(4)=gaussianWithDrag('Xm90',0,-pi/2,amplitude,dragAmplitude,sigma,cutoff,buffer);
            primitives(5)=gaussianWithDrag('Y180',pi/2,pi,amplitude,dragAmplitude,sigma,cutoff,buffer);
            primitives(6)=gaussianWithDrag('Y90',pi/2,pi/2,amplitude,dragAmplitude,sigma,cutoff,buffer);
            primitives(7)=gaussianWithDrag('Ym90',pi/2,-pi/2,amplitude,dragAmplitude,sigma,cutoff,buffer);
            obj.primitives=primitives;
        end
        
        function obj=initCliffords(obj) % generate object array of cliffords
            % call crazy code to randomly generate the decomposition of
            % cliffords into primitives.
            [cliffs,Clfrdstring]=SingleQubitCliffords();
            for ind1=1:length(cliffs)
                unitary=cliffs{ind1};
                primStrings=Clfrdstring{ind1};
                
                % traverse list of primitive names and find index for gate
                % object array
                primDecompInd = [];
                primDecomp = [];
                for ind2=1:length(primStrings)
                    if(strcmp(primStrings{ind2},'X90pPulse')==1)
                        primDecompInd = [primDecompInd 3];
                        primDecomp = [primDecomp obj.primitives(3)];
                    elseif(strcmp(primStrings{ind2},'X90mPulse')==1)
                        primDecompInd = [primDecompInd 4];
                        primDecomp = [primDecomp obj.primitives(4)];
                    elseif(strcmp(primStrings{ind2},'Y90pPulse')==1)
                        primDecompInd = [primDecompInd 6];
                        primDecomp = [primDecomp obj.primitives(6)];
                    elseif(strcmp(primStrings{ind2},'Y90mPulse')==1)
                        primDecompInd = [primDecompInd 7];
                        primDecomp = [primDecomp obj.primitives(7)];
                    elseif(strcmp(primStrings{ind2},'XpPulse')==1)
                        primDecompInd = [primDecompInd 2];
                        primDecomp = [primDecomp obj.primitives(2)];
                    elseif(strcmp(primStrings{ind2},'YpPulse')==1)
                        primDecompInd = [primDecompInd 5];
                        primDecomp = [primDecomp obj.primitives(5)];
                    elseif(strcmp(primStrings{ind2},'QIdPulse')==1)
                        primDecompInd = [primDecompInd 1];
                        primDecomp = [primDecomp obj.primitives(1)];
                    end
                end
                cliffords(ind1)=cliffordGate(ind1,unitary,primDecomp);
            end
            obj.cliffords=cliffords;
        end
            


                    % calculate peak times for the pulses in a subsequence waveform set
                    % generate a subsequence waveform 'set' (given a subsequence of primitives generate all waveforms)
                    % visualize subsequence waveform 'set'


    end
        
        
        
        
        
        
        

end
       