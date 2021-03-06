classdef ExperimentLibraryTemplate < handle
    % Example class definition for an experiment object in the style of
    % explib. A single qubit pulse at varying times - i.e. a T1 measurement
    %
    % Use:  
    % myExp = explib.ExperimentLibraryTemplate();
    % myExp.draw();
    % myWaveset = myExp.genWaveset_M8195A()
    % awg = M8195AWG();
    % awg.WavesetDownloadSegmentLibrary(correctedWaveset);
    % awg.WavesetRunPlaylist(correctedWaveset);
    % awg.WavesetSeqStop(correctedWaveset);
    
    
    properties
        % change these to tweak the experiment
        qubitFreq=5e9; % qubit frequency
        gateType = 'X180';
        delayList = 200e-9:1e-6:10.2e-6; % delay btw qubit pulses and measurement pulse
        cavityFreq=7e9; % cavity frequency
        measDuration = 5e-6;
        startBuffer = 1e-6; % buffer at beginning of waveform
        endBuffer = 50e-9; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        qubit; % qubit pulse object
        measurement; % measurement pulse object
        qubitPulseTimes; % calculated times for when pulses should occur (tCenter)
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=ExperimentLibraryTemplate()
            % constructor generates the necessary objects and calculates the dependent parameters
            
            % generate qubit object
            obj.qubit = pulselib.singleGate(obj.gateType);
            % generate measurement pulse
            obj.measurement=pulselib.measPulse(obj.measDuration);
            
            % calculate measurement pulse times - based on the max
            % delay btw qubit and measurement
            obj.measStartTime = obj.startBuffer + max(obj.delayList);
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
            
            % calculate qubit pulse times based on the measurement time and
            % the desired delays
            for ind = 1:length(obj.delayList)
                obj.qubitPulseTimes(ind)=obj.measStartTime-obj.delayList(ind);
            end
        end
        
        function draw(obj) 
            % It is often useful to be able to visualize the experiment for debugging purposes.
            
            % pulse objects are abstract. To get vector waveforms you pass them a time axis vector
            t = 0:1/obj.samplingRate:(obj.waveformEndTime);
            figure(145)
            
            % makes a movie stepping through the different waveforms
            for ind=1:length(obj.delayList)
                q=obj.qubit;
                % calling pulse object methods to generate waveforms
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTimes(ind));
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                subplot(2,1,1)
                plot(t,iQubitMod,'b',t,qQubitMod,'r')
                subplot(2,1,2)
                plot(t,iMeasMod,'b',t,qMeasMod,'r')
                pause(1)
            end
        end
        
        function w = genWaveset_M8195A(obj)
            % Implement a method such as this one to generate the files
            % for whatever AWG you are using.  Here is an example where we
            % use the M8195A. We create a waveset object to pass to the AWG
            % (paramlib.M8195A.waveset - see
            % ExampleCode\Using_waveset_objects)
            % You can make several different methods to generate different
            % outputs from the same experiment. For example if you want to
            % use the same experiment on a different AWG, or switch between
            % direct synthesis and outputting baseband signals.
            
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
            % end segment that can be repeated until next trigger
            wfEnd = zeros(1,(40e-9)/tStep);
            sEnd = w.newSegment(wfEnd,[1 0; 0 0; 1 0; 0 0]);
            for ind=1:length(obj.delayList)
                q=obj.qubit;
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTimes(ind));
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
       