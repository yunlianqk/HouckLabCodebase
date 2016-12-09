function Save(self)
    global card;
    
    path = self.savepath;
    if ~strcmp(path(end), filesep())
        path = [path, filesep()];
    end
    temppulseCal = self.pulseCal;
    
    result = self.result;
    self.pulseCal = funclib.obj2struct(self.pulseCal);
    x = funclib.obj2struct(self);
    cardparams = funclib.obj2struct(card.params);
    save([path, self.savefile], 'x', 'result', 'cardparams');
    display(['Data saved to ', path, self.savefile]);
    self.pulseCal = temppulseCal;
end