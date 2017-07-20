function Normalize(self)
% Normalize data

    % For histogram, do not normalize
    if self.histogram
        return;
    end

    if self.normalization
        gndI = self.result.intI(end-1);
        extI = self.result.intI(end);
        gndQ = self.result.intQ(end-1);
        extQ = self.result.intQ(end);
        self.result.normAmp ...
            = sqrt((self.result.intI(1:end-2)-gndI).^2 ...
                   + (self.result.intQ(1:end-2)-gndQ).^2) ...
              / sqrt((extI-gndI)^2+(extQ-gndQ)^2);
    end
end