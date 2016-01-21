% Close existing instruments
if (exist('rfgen', 'var'))
    rfgen.Finalize();
    clear('rfgen');
end

if (exist('specgen', 'var'))
    specgen.Finalize();
    clear('specgen');
end

if (exist('logen', 'var'))
    logen.Finalize();
    clear('logen');
end

if (exist('pnax', 'var'))
    pnax.Finalize();
    clear('pnax');
end

if (exist('yoko', 'var'))
    yoko.Finalize();
    clear('yoko');
end

if (exist('triggen', 'var'))
    triggen.Finalize();
    clear('triggen');
end

if (exist('card', 'var'))
    card.Finalize();
    clear('card');
end

if (exist('pulsegen', 'var'))
    pulsegen.Finalize();
    clear('pulsegen');
end

% Final house keeping
if (~isempty(instrfind))
    fclose(instrfind);
    delete(instrfind);
end