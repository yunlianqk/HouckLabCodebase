classdef RabiExperiment < handle
    % Simple Rabi Experiment. X pulse with varying power. JJR 2016, Princeton
    
    properties
        qubit; % object array of qubit pulses
        measurement; % measurement pulse object
        ampList = linspace(1,0,101);
        qubitStartTime = 200e-9; % delay in seconds after qubit pulse before measurement pulse
        qubitPulseTime;
        qubitEndTime; % automatically calculated
        measDelay = 50e-9; % time in seconds btw qubit pulse and start of measurement pulse 
        measStartTime; % starts shortly after end of the rbSequence 
        measEndTime;
        waveformEndDelay = 50e-9; % delay after end of measurement pulse to end waveform
        qubitFreq=5e9; % qubit frequency
        cavityFreq=7e9; % cavity frequency
        samplingRate=32e9; % sampling rate
    end
    
    methods
        function obj=RabiExperiment()% constructor
            obj.initQubitPulse();
            obj.initMeasPulse();
        end
        
        function obj=initQubitPulse(obj)
            % qubit pulse parameters
            sigma=10e-9; % gaussian width in seconds
            cutoff=4*sigma;  % force pulse tail to zero. this is the total time the pulse is nonzero in seconds
            buffer=4e-9; % extra time beyond the cutoff to separate gates.  this is the total buffer, so half before and half after.
            dragFactor=.1; % drag amplitude relative to main gaussian
            for ind=1:length(obj.ampList)
                amp=obj.ampList(ind);
                dragAmp=amp*dragFactor;
                qubit(ind)=pulselib.gaussianWithDrag('X180',0,pi,amp,dragAmp,sigma,cutoff,buffer);
            end
            obj.qubit=qubit;
            obj.qubitPulseTime=obj.qubitStartTime+obj.qubit(1).totalPulseDuration/2;
            obj.qubitEndTime=obj.qubitStartTime+obj.qubit(1).totalPulseDuration;
        end
        
        function obj=initMeasPulse(obj)
            % generate measurement pulse
            obj.measurement=pulselib.rectMeasurementPulse(0,1,1e-6);
            obj.measStartTime=obj.qubitEndTime+obj.measDelay;
            obj.measEndTime=obj.measStartTime+obj.measurement.duration;
        end
        
        function draw(obj)
            t = 0:1/obj.samplingRate:(obj.measEndTime+obj.waveformEndDelay);
            figure(145)
            for ind=1:length(obj.qubit)
                q=obj.qubit(ind);
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTime);
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                subplot(2,1,1)
%                 plot(t,iQubitBaseband,'b',t,qQubitBaseband,'r')
%                 subplot(2,1,2)
%                 plot(t,iMeasBaseband,'b',t,qMeasBaseband,'r')
                plot(t,iQubitMod,'b',t,qQubitMod,'r')
                subplot(2,1,2)
                plot(t,iMeasMod,'b',t,qMeasMod,'r')
                
                pause(1)
            end
        end
        
        function w = genWaveset_M8195A_directSynthesis(obj)
            % build waveset object for use with M8195A AWG
            % this makes each trial (or pulse power) its own segment.
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.measEndTime+obj.waveformEndDelay);
            % end segment that can be repeated until next trigger
            wfEnd = zeros(1,(40e-9)/tStep);
            sEnd = w.newSegment(wfEnd,[1 0; 0 0; 1 0; 0 0]);
            for ind=1:length(obj.qubit)
                q=obj.qubit(ind);
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTime);
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
                ch3waveform = iMeasMod+qMeasMod;
                s1=w.newSegment(ch1waveform);
                p1=w.newPlaylistItem(s1);
                pEnd=w.newPlaylistItem(sEnd);
                pEnd.advance='Conditional';
                % since s2 will be played simultaneously with s1, it does
                % not need its own playlist item!
                s2=w.newSegment(ch3waveform,[0 0; 0 0; 1 0; 0 0]);
                s2.id=s1.id;
            end
        end
        
        function w = genWaveset_M8195A_baseband(obj)
            % build waveset object for use with M8195A AWG
            % outputs baseband signals on separate channels.
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.measEndTime+obj.waveformEndDelay);
            % end segment that can be repeated until next trigger
            wfEnd = zeros(1,(40e-9)/tStep);
            sEnd = w.newSegment(wfEnd,[1 0; 1 0; 1 0; 1 0]);
            for ind=1:length(obj.qubit)
                q=obj.qubit(ind);
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTime);
                ch1waveform = iQubitBaseband;
                ch2waveform = qQubitBaseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                ch3waveform = iMeasBaseband;
                ch4waveform = qMeasBaseband;
                s1=w.newSegment(ch1waveform);
                s2=w.newSegment(ch2waveform,[0 0; 1 0; 0 0; 0 0]);
                s2.id=s1.id;
                s3=w.newSegment(ch3waveform,[0 0; 0 0; 1 0; 0 0]);
                s3.id=s1.id;
                s4=w.newSegment(ch4waveform,[0 0; 0 0; 0 0; 1 0]);
                s4.id=s1.id;
                % segments played together only have 1 playlist entry
                p1=w.newPlaylistItem(s1);
                pEnd=w.newPlaylistItem(sEnd);
                pEnd.advance='Conditional';
            end
        end
    end
end
       