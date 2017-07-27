function Normalize(self)
% Normalize data

    % For histogram, do not normalize
    if self.histogram
        return;
    end
    numTomoGates=self.numTomoGates; % number of gates in tomography
    self.result.normalization = self.normalization;
    self.result.cardchannel = self.cardchannel;
    if self.normalization
        gndI = self.result.intI(end-1);
        extI = self.result.intI(end);
        gndQ = self.result.intQ(end-1);
        extQ = self.result.intQ(end);
        if length(self.cardchannel) == 1
        % If cardchannel = 'dataIQ' or 'dataI' or 'dataQ'
            self.result.normAmp ...
                = sqrt((self.result.intI(1:end-2-self.tomography*numTomoGates)-gndI).^2 ...
                       + (self.result.intQ(1:end-2-self.tomography*numTomoGates)-gndQ).^2) ...
                  / sqrt((extI-gndI)^2+(extQ-gndQ)^2);
        else
        % If cardchannel = {'dataI', 'dataQ'}
            if self.result.intFreq == 0
            % Homodyne
                self.result.normAmp = (self.result.intI(1:end-2-self.tomography*numTomoGates)-gndI)/(extI-gndI);
                self.result.normAmp2 = (self.result.intQ(1:end-2-self.tomography*numTomoGates)-gndQ)/(extQ-gndQ);
            else
            % Heterodyne
                gndI2 = self.result.intI2(end-1-self.tomography*numTomoGates);
                extI2 = self.result.intI2(end-self.tomography*numTomoGates);
                gndQ2 = self.result.intQ2(end-1-self.tomography*numTomoGates);
                extQ2 = self.result.intQ2(end-self.tomography*numTomoGates);

                self.result.normAmp ...
                = sqrt((self.result.intI(1:end-2-self.tomography*numTomoGates)-gndI).^2 ...
                       + (self.result.intQ(1:end-2-self.tomography*numTomoGates)-gndQ).^2) ...
                  / sqrt((extI-gndI)^2+(extQ-gndQ)^2);
                self.result.normAmp2 ...
                = sqrt((self.result.intI2(1:end-2-self.tomography*numTomoGates)-gndI2).^2 ...
                       + (self.result.intQ2(1:end-2-self.tomography*numTomoGates)-gndQ2).^2) ...
                  / sqrt((extI2-gndI2)^2+(extQ2-gndQ2)^2);
            end
        end
    end
end