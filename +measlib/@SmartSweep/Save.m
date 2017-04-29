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
    end
    % If filename is specified as input, set path to pwd
    if nargin == 2
        path = [pwd(), filesep()];
    end
    
    % Convert pulseCal to struct
    if isprop(self, 'pulseCal')
        temppulseCal = self.pulseCal;
        self.pulseCal = funclib.obj2struct(self.pulseCal);
    end
    % Convert x to struct
    x = funclib.obj2struct(self);
    % Save data
    try
        % Save cardparams if possible
        cardparams = funclib.obj2struct(card.params);
        save([path, filename], 'x', 'cardparams');
    catch
        save([path, filename], 'x');
    end
    display(['Data saved to ', path, filename]);
    % Recover pulseCal object
    if isprop(self, 'pulseCal')
        self.pulseCal = temppulseCal;
    end
end