function Save(self, filename)
    global card;
    
    % If savepath is empty, use default path
    if isempty(self.savepath)
        self.savepath = 'C:\Data\';
    end
    
    % Add '/' to the end of path if necessary
    path = self.savepath;
    if ~strcmp(path(end), filesep())
        path = [path, filesep()];
    end
    
    % If path does not exist, create it
    if ~exist(path, 'dir')
        mkdir(path);
    end

    % If filename is not specified, use default name
    if nargin == 1
        filename = self.savefile;
    elseif nargin == 2
        path = [pwd(), filesep()];
    end
    
    % Convert pulseCal to struct
    if isprop(self, 'pulseCal')
        pulseCal = self.pulseCal;
        self.pulseCal = funclib.obj2struct(self.pulseCal);
    end
    
    if isprop(self, 'pulseCal2')
        pulseCal2 = self.pulseCal2;
        self.pulseCal2 = funclib.obj2struct(self.pulseCal2);
    end
    
    % Convert x to struct
    x = funclib.obj2struct(self);
    
    % Clear instrument objects as it causes matlab crash
    awg = x.awg;
    generator = x.generator;
    x.awg = [];
    x.generator = [];
    
    % Save data
    try
        % Save cardparams if possible
        cardparams = funclib.obj2struct(card.params);
        save([path, filename], 'x', 'cardparams');
    catch
        save([path, filename], 'x');
    end
    display(['Data saved to ', path, filename]);
    
    % Recover pulseCal object and instrument objects
    if isprop(self, 'pulseCal')
        self.pulseCal = pulseCal;
    end
    if isprop(self, 'pulseCal2')
        self.pulseCal2 = pulseCal2;
    end
    x.awg = awg;
    x.generator = generator;
end