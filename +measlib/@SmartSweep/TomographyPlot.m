function TomographyPlot(self)
% Normalize data

    % For histogram, do not plot tomography
    if self.histogram
        return;
    end
    numTomoGates=self.numTomoGates; % number of gates in tomography
    self.result.normalization = self.normalization;
    self.result.cardchannel = self.cardchannel;
    if self.tomography && self.normalization % need to have normalization ON for tomography
        gndI = self.result.intI(end-1-self.tomography*numTomoGates);
        extI = self.result.intI(end-self.tomography*numTomoGates);
        gndQ = self.result.intQ(end-1-self.tomography*numTomoGates);
        extQ = self.result.intQ(end-self.tomography*numTomoGates);
        if length(self.cardchannel) == 1
        % If cardchannel = 'dataIQ' or 'dataI' or 'dataQ'
            self.result.TomoAmp ...
                = sqrt((self.result.intI(end-self.tomography*numTomoGates+1:end)-gndI).^2 ...
                       + (self.result.intQ(end-self.tomography*numTomoGates+1:end)-gndQ).^2) ...
                  / sqrt((extI-gndI)^2+(extQ-gndQ)^2);
            % Plot tomography
            figure(999);
            plot(1:numTomoGates, self.result.TomoAmp, '-o');
            set(gca, 'xtick', 1:numTomoGates);
            set(gca, 'xticklabel', {'Id','X90','Y90'});
            set(gca, 'xticklabelrotation', 45);
            axis([0, numTomoGates+1, -0.2, 1.2]);
            plotlib.hline(1);
            plotlib.hline(0);
            plotlib.hline(0.5);
            hold on;
            for ind = 1:numTomoGates
                plot([ind, ind], [-0.2, self.result.TomoAmp(ind)], 'r:');
            end
            hold off;
            title([self.name,'Tomography']);
            ylabel('P(|0>)');
			drawnow;

        else
        % If cardchannel = {'dataI', 'dataQ'}
            if self.result.intFreq == 0
            % Homodyne
                self.result.TomoAmp = (self.result.intI(end-self.tomography*numTomoGates+1:end)-gndI)/(extI-gndI);
                self.result.TomoAmp2 = (self.result.intQ(end-self.tomography*numTomoGates+1:end)-gndQ)/(extQ-gndQ);
            else
            % Heterodyne
                gndI2 = self.result.intI2(end-1-self.tomography*numTomoGates);
                extI2 = self.result.intI2(end-self.tomography*numTomoGates);
                gndQ2 = self.result.intQ2(end-1-self.tomography*numTomoGates);
                extQ2 = self.result.intQ2(end-self.tomography*numTomoGates);

                self.result.TomoAmp ...
                = sqrt((self.result.intI(end-self.tomography*numTomoGates+1:end)-gndI).^2 ...
                       + (self.result.intQ(end-self.tomography*numTomoGates+1:end)-gndQ).^2) ...
                  / sqrt((extI-gndI)^2+(extQ-gndQ)^2);
                self.result.TomoAmp2 ...
                = sqrt((self.result.intI2(end-self.tomography*numTomoGates+1:end)-gndI2).^2 ...
                       + (self.result.intQ2(end-self.tomography*numTomoGates+1:end)-gndQ2).^2) ...
                  / sqrt((extI2-gndI2)^2+(extQ2-gndQ2)^2);
            end
            % Plot tomography
            figure(999);
            plot(1:numTomoGates, self.result.TomoAmp, '-o');
            set(gca, 'xtick', 1:numTomoGates);
            set(gca, 'xticklabel', {'Id','X90','Y90'});
            set(gca, 'xticklabelrotation', 45);
            axis([0, numTomoGates+1, -0.2, 1.2]);
            plotlib.hline(1);
            plotlib.hline(0);
            plotlib.hline(0.5);
            hold on;
            for ind = 1:numTomoGates
                plot([ind, ind], [-0.2, self.result.TomoAmp(ind)], 'r:');
            end
            hold off;
            title([self.name,'_Q1Tomography']);
            ylabel('P(|0>)');
			drawnow;
            
            figure(998);
            plot(1:numTomoGates, self.result.TomoAmp2, '-o');
            set(gca, 'xtick', 1:numTomoGates);
            set(gca, 'xticklabel', {'Id','X90','Y90'});
            set(gca, 'xticklabelrotation', 45);
            axis([0, numTomoGates+1, -0.2, 1.2]);
            plotlib.hline(1);
            plotlib.hline(0);
            plotlib.hline(0.5);
            hold on;
            for ind = 1:numTomoGates
                plot([ind, ind], [-0.2, self.result.TomoAmp2(ind)], 'r:');
            end
            hold off;
            title([self.name,'_Q2Tomography']);
            ylabel('P(|0>)');
			drawnow;

        end
    end
end