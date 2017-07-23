function obj = Load(filename)
% Load .mat and return SmartSweep object
    s = load(filename);
    try
        x = s.x;
        if isfield(x, 'pulseCal2')
            x.pulseCal2 = funclib.struct2obj(x.pulseCal2, paramlib.pulseCal());
        end
        if isfield(x, 'pulseCal')
            x.pulseCal = funclib.struct2obj(x.pulseCal, paramlib.pulseCal());
            try
                obj = funclib.struct2obj(x, eval(['measlib.', x.name, '(x.pulseCal)']));
            catch
                obj = funclib.struct2obj(x, eval(['measlib.', x.name, '(x.pulseCal, x.pulseCal2)']));
            end
        else
            obj = funclib.struct2obj(x, eval(['measlib.', x.name, '()']));
        end
    catch
        error('Cannot load measlib object from file.');
    end
    display(['Data loaded from ', filename]);
end