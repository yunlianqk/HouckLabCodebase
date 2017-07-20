function ModOff(self)
% Set to CW mode
    fprintf(self.instrhandle, 'PULM:STATe 0');
    if strfind(self.Info(), 'E8267D')
        % Only E8267D has wideband I/Q modulation
        fprintf(self.instrhandle, 'WDM:STATe 0');
    end
    fprintf(self.instrhandle, 'POWer:ALC 1');
    fprintf(self.instrhandle, 'OUTPut:MODulation 0');
end