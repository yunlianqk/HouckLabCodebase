function Save(self)
    global card;
    
    path = self.savepath;
    if ~strcmp(path(end), filesep())
        path = [path, filesep()];
    end
        
    if isprop(self, 'pulseCal')
        temppulseCal = self.pulseCal;
        self.pulseCal = funclib.obj2struct(self.pulseCal);
    end
    x = funclib.obj2struct(self);
    cardparams = funclib.obj2struct(card.params);
    save([path, self.savefile], 'x', 'cardparams');
    display(['Data saved to ', path, self.savefile]);
    if isprop(self, 'pulseCal')
        self.pulseCal = temppulseCal;
    end
end