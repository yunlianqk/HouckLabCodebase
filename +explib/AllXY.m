classdef AllXY < explib.ArbGates
    
    methods
        function self = AllXY(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.ArbGates(pulseCal, config);
            self.qubitGates = {{'Identity', 'Identity'}, ...
                               {'X180', 'X180'}, ...
                               {'Y180', 'Y180'}, ...
                               {'X180', 'Y180'}, ...
                               {'X90', 'Identity'}, ...
                               {'Y90', 'Identity'}, ...
                               {'X90', 'Y90'}, ...
                               {'Y90', 'X90'}, ...
                               {'X90', 'Y180'}, ...
                               {'Y90', 'X180'}, ...
                               {'X90', 'X180'}, ...
                               {'X180', 'X90'}, ...
                               {'Y90', 'Y180'}, ...
                               {'Y180', 'Y90'}, ...
                               {'X180', 'Identity'}, ...
                               {'Y180', 'Identity'}, ...
                               {'X90', 'X90'}, ...
                               {'Y90', 'Y90'}};
        end
        
        function Run(self)
            Run@explib.ArbGates(self);
            self.Plot();
        end
        
        function Plot(self)
            numseq = length(self.qubitGates);
            ticklabels = cell(1, numseq);
            for row = 1:numseq
                gates = self.qubitGates{row};
                for col = 1:length(gates)
                    switch gates{col}
                        case 'Identity'
                            ticklabels{row} = [ticklabels{row}, 'Id'];
                        case 'X180'
                            ticklabels{row} = [ticklabels{row}, 'Xp'];
                        case 'X90'
                            ticklabels{row} = [ticklabels{row}, 'X9'];
                        case 'Y180'
                            ticklabels{row} = [ticklabels{row}, 'Yp'];
                        case 'Y90'
                            ticklabels{row} = [ticklabels{row}, 'Y9'];
                        otherwise
                            display(['Unknown gate: ', gates{col}]);
                    end
                end
            end
            figure(187);
            plot(1:numseq, self.result.AmpInt, '-o');
            set(gca, 'xtick', 1:numseq);
            set(gca, 'xticklabel', ticklabels);
            set(gca, 'xticklabelrotation', 45);
            axis([0, numseq+1, -0.2, 1.2]);
            plotlib.hline(1);
            plotlib.hline(0);
            plotlib.hline(0.5);
            hold on;
            for ind = 1:numseq
                plot([ind, ind], [-0.2, self.result.AmpInt(ind)], 'r:');
            end
            hold off;
            title(self.experimentName);
            ylabel('P(|0>)');
			drawnow;
        end
    end
end     