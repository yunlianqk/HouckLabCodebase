function ModOn(self)
% Set to pulse mode
    fprintf(self.instrhandle, 'PULM:STATe 1');
    fprintf(self.instrhandle, 'PULM:SOURce EXT');
    if strfind(self.Info(), 'E8267D')
        % Only E8267D has wideband I/Q modulation
        fprintf(self.instrhandle, 'WDM:STATe 1');
    end
    fprintf(self.instrhandle, 'POWer:ALC 0');
    fprintf(self.instrhandle, 'OUTPut:MODulation 1');
end