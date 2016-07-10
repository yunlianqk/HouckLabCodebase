classdef fluxController < handle
    %fluxController Interface for controlling flux lines for tunable dimer
    %   Should contain everything for converting, setting and visualizing
    %   trajectories and points in flux and voltage space.  In flux space,
    %   vectors defined as [Left Qubit; Right Qubit; Coupler] and in
    %   voltage space as [Yoko 1; Yoko 2; Yoko 3]
    
    properties
        crossCouplingMatrix = eye(3); % default set to uncoupled... but now never used
        fluxOffset = [0; 0; 0]; % default is no flux offset... but now never used
    end
    properties (Dependent)
        currentVoltage
        currentFlux
        fluxTrajectory
        voltageTrajectory
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
            % move yokos together to prevent unwanted flux excursions
            startVoltage=obj.currentVoltage;
            stopVoltage=value;
            steps = round(abs(stopVoltage - startVoltage)./[yoko1.rampstep; yoko2.rampstep; yoko3.rampstep]);
            maxSteps = max(steps);
            vtraj=obj.generateTrajectory(startVoltage,stopVoltage, maxSteps);
            for index=1:maxSteps
                yoko1.SetVoltage(vtraj(1,index));
                yoko2.SetVoltage(vtraj(2,index));
                yoko3.SetVoltage(vtraj(3,index));
            end
        end
        function currentVoltage=get.currentVoltage(obj) % queries the yokos and returns the voltages
            global yoko1
            global yoko2
            global yoko3
            yoko1.GetVoltage();
            yoko2.GetVoltage();
            yoko3.GetVoltage();
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

