classdef FluxPump < measlib.SmartSweep

    properties
        durationVector = linspace(0, 5e-6, 101);
        amplitude = 1.0;
        sigma = 10e-9;
        fluxBuffer = 100e-9;
    end
    
    methods
        function self = FluxPump(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
        end

        function SetUp(self)
            X180 = self.pulseCal.X180();
            self.fluxseq = pulselib.gateSequence();
            self.gateseq = pulselib.gateSequence();
            for row = 1:length(self.durationVector)
                % Define rectangular pulse as flux drive
                fluxpulse = pulselib.measPulse(self.durationVector(row));
                fluxpulse.amplitude = self.amplitude;
                fluxpulse.sigma = self.sigma;
                fluxpulse.buffer = self.pulseCal.buffer;
                self.fluxseq(row) = pulselib.gateSequence(fluxpulse);
                % Define pi pulse + delay as qubit drive
                self.gateseq(row) = pulselib.gateSequence(X180);
                self.gateseq(row).append(pulselib.delay( ...
                                            fluxpulse.totalDuration ...
                                            + self.fluxBuffer));
            end
            self.result.rowAxis = self.durationVector;
            SetUp@measlib.SmartSweep(self);
        end
    end
end
