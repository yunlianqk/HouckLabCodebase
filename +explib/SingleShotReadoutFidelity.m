classdef SingleShotReadoutFidelity < explib.SweepM8195
    
    methods
        function self = SingleShotReadoutFidelity(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.SweepM8195(pulseCal, config);
        end
    
        function SetUp(self)
            self.bgsubtraction = 0;
            self.normalization = 0;
            self.histogram = 1;
            self.sequences = pulselib.gateSequence();
            self.sequences(1) = pulselib.gateSequence(self.pulseCal.Identity());
            self.sequences(2) = pulselib.gateSequence(self.pulseCal.X180());
            SetUp@explib.SweepM8195(self);
        end
        
        function Run(self)
            Run@explib.SweepM8195(self);
            self.Plot();
        end
        
        function Plot(self)
            gndCDF = cumsum(self.result.AmpCounts(1, :))/sum(self.result.AmpCounts(1, :));
            exCDF = cumsum(self.result.AmpCounts(2, :))/sum(self.result.AmpCounts(2, :));
            [self.result.AmpFidelity, threshInd] = max(abs(gndCDF-exCDF));
            self.result.AmpThreshold = (self.result.AmpEdges(threshInd)+self.result.AmpEdges(threshInd+1))/2;
            figure(691);
            subplot(2, 2, 1);
            plot(self.result.AmpEdges(2:end), self.result.AmpCounts(1, :), 'b');
            hold on;
            plot(self.result.AmpEdges(2:end), self.result.AmpCounts(2, :), 'r');
            plotlib.vline(self.result.AmpThreshold);
            hold off;
            xlabel('Amplitude');
            ylabel('Counts');
            legend('|g\rangle', '|e\rangle');
            title('Amplitude');
            subplot(2, 2, 3);
            plot(self.result.AmpEdges(2:end), gndCDF, 'b');
            hold on;
            plot(self.result.AmpEdges(2:end), exCDF, 'r');
            plotlib.vline(self.result.AmpThreshold);
            hold off;
            xlabel('Amplitude');
            ylabel('Cumulative counts');
            title(['Fidelity: ', num2str(self.result.AmpFidelity), ...
                   ', threshold: ', num2str(self.result.AmpThreshold)]);
               
            gndCDF = cumsum(self.result.PhaseCounts(1, :))/sum(self.result.PhaseCounts(1, :));
            exCDF = cumsum(self.result.PhaseCounts(2, :))/sum(self.result.PhaseCounts(2, :));
            [self.result.PhaseFidelity, threshInd] = max(abs(gndCDF-exCDF));
            self.result.PhaseThreshold = (self.result.PhaseEdges(threshInd)+self.result.PhaseEdges(threshInd+1))/2;
            figure(691);
            subplot(2, 2, 2);
            plot(self.result.PhaseEdges(2:end), self.result.PhaseCounts(1, :), 'b');
            hold on;
            plot(self.result.PhaseEdges(2:end), self.result.PhaseCounts(2, :), 'r');
            plotlib.vline(self.result.PhaseThreshold);
            hold off;
            xlabel('Phase');
            ylabel('Counts');
            title('Phase');
            subplot(2, 2, 4);
            plot(self.result.PhaseEdges(2:end), gndCDF, 'b');
            hold on;
            plot(self.result.PhaseEdges(2:end), exCDF, 'r');
            plotlib.vline(self.result.PhaseThreshold);
            hold off;
            xlabel('Phase');
            ylabel('Cumulative counts');
            title(['Fidelity: ', num2str(self.result.PhaseFidelity), ...
                   ', threshold: ', num2str(self.result.PhaseThreshold)]);
	        drawnow;
        end
    end
end


        
        
        