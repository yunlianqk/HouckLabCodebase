function Normalize(self)
% Normalize data

    % For histogram, do not normalize
    if self.histogram
        return;
    end
    self.result.normalization = self.normalization;
    self.result.tomography = self.tomography;
    self.result.cardchannel = self.cardchannel;
    if self.normalization
        gndI = self.result.intI(end-1);
        extI = self.result.intI(end);
        gndQ = self.result.intQ(end-1);
        extQ = self.result.intQ(end);
        if length(self.cardchannel) == 1
        % If cardchannel = 'dataIQ' or 'dataI' or 'dataQ'
            self.result.normAmp ...
                = sqrt((self.result.intI(1:end-2)-gndI).^2 ...
                       + (self.result.intQ(1:end-2)-gndQ).^2) ...
                  / sqrt((extI-gndI)^2+(extQ-gndQ)^2);
        else
        % If cardchannel = {'dataI', 'dataQ'}
            if self.result.intFreq == 0
            % Homodyne
                self.result.normAmp = (self.result.intI(1:end-2)-gndI)/(extI-gndI);
                self.result.normAmp2 = (self.result.intQ(1:end-2)-gndQ)/(extQ-gndQ);
            else
            % Heterodyne
                gndI2 = self.result.intI2(end-1);
                extI2 = self.result.intI2(end);
                gndQ2 = self.result.intQ2(end-1);
                extQ2 = self.result.intQ2(end);

                self.result.normAmp ...
                = sqrt((self.result.intI(1:end-2)-gndI).^2 ...
                       + (self.result.intQ(1:end-2)-gndQ).^2) ...
                  / sqrt((extI-gndI)^2+(extQ-gndQ)^2);
                self.result.normAmp2 ...
                = sqrt((self.result.intI2(1:end-2)-gndI2).^2 ...
                       + (self.result.intQ2(1:end-2)-gndQ2).^2) ...
                  / sqrt((extI2-gndI2)^2+(extQ2-gndQ2)^2);
            end
        end
        if self.tomography
            self.result.tomoAmp = self.result.normAmp(end-2:end);
            self.result.normAmp(end-2:end) = [];
            if length(self.cardchannel) == 2
                self.result.tomoAmp2 = self.result.normAmp2(end-2:end);
                self.result.normAmp2(end-2:end) = [];
            end  
        end   
    end
end