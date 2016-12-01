function Save(self)
    path = self.savepath;
    if ~strcmp(path(end), filesep())
        path = [path, filesep()];
    end
    result = self.result;
    temppulseCal = self.pulseCal;
    self.pulseCal = funclib.obj2struct(self.pulseCal);
    x = funclib.obj2struct(self);
    save([path, self.savefile], 'x', 'result');
    display(['Data saved to ', path, self.savefile]);
    self.pulseCal = temppulseCal;
end