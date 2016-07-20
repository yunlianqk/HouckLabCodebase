classdef fluxController2 < handle
    %fluxController Interface for controlling flux lines for tunable dimer
    %   Should contain everything for converting, setting and visualizing
    %   trajectories and points in flux and voltage space.  In flux space,
    %   vectors defined as [Left Qubit; Right Qubit; Coupler] and in
    %   voltage space as [Yoko 1; Yoko 2; Yoko 3]
    
    properties
        crossCouplingMatrix = eye(3); % default set to uncoupled... but now never used
        fluxOffset = [0; 0; 0]; % default is no flux offset... but now never used
        % set up function handles for converting flux to frequency and
        % coupling. Swap these out with the fit functions
        % E.G. use @(x) sqrt(8.*Ec.*EjSum.*abs(cos(pi.*x))-Ec;
        leftQubitFluxToFreqFunc = @(x) x;
        rightQubitFluxToFreqFunc = @(x) x;
        couplerFluxToCavityFreqFunc = @(x) x;
        couplerFluxToCouplingFunc = @(x) x;
        
    end
    properties (Dependent)
        currentVoltage
        currentFlux
        currentFrequency
        fluxTrajectory
        voltageTrajectory
        frequencyTrajectory
    end
    
    methods
        function obj=fluxController(crossCouplingMatrix, fluxOffset) % constructor method requires you provide the calibration values
            obj.crossCouplingMatrix=crossCouplingMatrix;
            obj.fluxOffset=fluxOffset;
        end
        function set.currentVoltage(obj,value) % value is point of voltages [yoko1; yoko2; yoko3].  Also caclulates flux and sets that value
            if size(value,1)==1
                value=value';
            end
            global yoko1
            global yoko2
            global yoko3
            yoko1.SetVoltage(value(1));
            yoko2.SetVoltage(value(2));
            yoko3.SetVoltage(value(3));
        end
        function currentVoltage=get.currentVoltage(obj) % queries the yokos and returns the voltages
            global yoko1
            global yoko2
            global yoko3
            yoko1.GetVoltage()
            yoko2.GetVoltage()
            yoko3.GetVoltage()
            currentVoltage = [yoko1.voltage; yoko2.voltage; yoko3.voltage];
        end
        function set.currentFlux(obj,value) % take flux point as input and set currentVoltage
            if size(value,1)==1
                value=value';
            end
            voltage = obj.calculateVoltagePoint(value);
            obj.currentVoltage=voltage;
        end
        function currentFlux=get.currentFlux(obj) % queries yokos to find current voltage, then calculates current flux
            voltage = obj.currentVoltage;
            currentFlux = obj.calculateFluxPoint(voltage);
        end
        
        % set and get for freq map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.currentFrequency(obj,value) % take frequency point as input and set currentVoltage
            % to do
        end
        function currentFreq=get.currentFrequency(obj) % queries yokos to find current voltage, then calculates current flux
            currentFreq=1;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function flux=calculateFluxPoint(obj,value) %use provided voltage point to calculate flux point
            if size(value,1)==1
                value=value';
            end
            voltage = value;
            CM = obj.crossCouplingMatrix;
            f0 = obj.fluxOffset;
            flux = CM * voltage + f0;
        end
        function voltage=calculateVoltagePoint(obj,value) %use provided flux point to calculate voltage point
            if size(value,1)==1
                value=value';
            end
            flux = value;
            CM = obj.crossCouplingMatrix;
            f0 = obj.fluxOffset;
            % voltage = inv(CM) * (flux - f0); this is apparently slow and innacurate...
            voltage = CM\(flux - f0);
        end
        
        %%%% Calculate things using flux to freq mappings %%%%%%%%%%%%%%%%%%%%%%%
        
        function frequency = calculateRightQubitFrequency(obj,value)
            frequency = obj.rightQubitFluxToFreqFunc(flux);
        end
           
        function flux = calculateRightQubitFluxFromFrequency(obj,value)
            % assumes flux from 0 to .5
            freq = value;
            fluxVector = linspace(0,.5,10000);
            freqVector = obj.rightQubitFluxToFreqFunc(fluxVector);
            asdf = 1
            
        end
            
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%
        
        
        function trajectory=generateTrajectory(obj,start,stop, steps) %uses two flux points to create a linear flux trajectory
            trajectory=[];
            trajectory(1,:)=linspace(start(1),stop(1),steps);
            trajectory(2,:)=linspace(start(2),stop(2),steps);
            trajectory(3,:)=linspace(start(3),stop(3),steps);
        end
        function fluxTrajectory = calculateFluxTrajectory(obj, voltageTrajectory) % generates the fluxTrajectory for a given voltageTrajectory
            fluxTrajectory=zeros(size(voltageTrajectory));
            for ind=1:size(fluxTrajectory,2)
                voltagePoint=voltageTrajectory(:,ind);
                fluxPoint=obj.calculateFluxPoint(voltagePoint);
                fluxTrajectory(:,ind)=fluxPoint;
            end
        end
        function voltageTrajectory = calculateVoltageTrajectory(obj, fluxTrajectory) % generates the fluxTrajectory for a given voltageTrajectory
            voltageTrajectory=zeros(size(fluxTrajectory));
            for ind=1:size(voltageTrajectory,2)
                fluxPoint=fluxTrajectory(:,ind);
                voltagePoint=obj.calculateVoltagePoint(fluxPoint);
                voltageTrajectory(:,ind)=voltagePoint;
            end
        end
        function visualizeTransform(obj)
            % first draw the yoko space unit vectors
            line = linspace(0,1,100);
            noline = zeros(1,100);
            X = [line; noline; noline];
            Y = [noline; line; noline];
            Z = [noline; noline; line];
            figure();
            plot3(X',Y',Z')
            
        end
        function visualizeTrajectories(obj,voltageTrajectory,fluxTrajectory) % pass both trajectories and get a nice visualization
            % use scatter plot to visualize
            figure();
            subplot(1,2,1)
            scatter3(voltageTrajectory(1,:),voltageTrajectory(2,:),voltageTrajectory(3,:))
            title('Voltage Trajectory'),xlabel('yoko1'),ylabel('yoko2'),zlabel('yoko3')
            subplot(1,2,2)
            scatter3(fluxTrajectory(1,:),fluxTrajectory(2,:),fluxTrajectory(3,:))
            title('Flux Trajectory'),xlabel('Left Qubit'),ylabel('Right Qubit'),zlabel('Coupler')
        end
    end
end

