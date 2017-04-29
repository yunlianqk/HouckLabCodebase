function obj = Load(filename)
    s = load(filename);
    
    try
        x = s.x;
        if isfield(x, 'pulseCal')
            x.pulseCal = funclib.struct2obj(x.pulseCal, paramlib.pulseCal());
            obj = funclib.struct2obj(x, eval(['measlib.', x.name, '(x.pulseCal)']));
        else
            obj = funclib.struct2obj(x, eval(['measlib.', x.name, '()']));
        end
    catch
        error('Cannot load measlib object from file.');
    end
    display(['Data loaded from ', filename]);
end