function Save(self, path)
    if nargin == 1
        path = self.savepath;
    end
    if ~strcmp(path(end), filesep())
        path = [path, filesep()];
    end
    result = self.result;
    x = paramlib.obj2struct(self);
    filename = [path, self.experimentName, '_', datestr(now(), 'yyyymmddHHMMSS'), '.mat'];
    save(filename, 'x', 'result');
    display(['Data saved to ', filename]);
end