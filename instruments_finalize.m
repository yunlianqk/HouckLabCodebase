% Close existing instruments
instrlist = {'E8267DGenerator', ...
             'PNAXAnalyzer', ...
             'YOKOGS200', ...
             'YOKO7651', ...
             'AWG33250A', ...
             'U1082ADigitizer', ...
             'U1084ADigitizer', ...
             'M9330AWG'};

% Finalize and clear any variable that belongs to above classes
varlist = who();
for index = 1:length(varlist)
    if ismember(class(eval(varlist{index})), instrlist)
        eval([varlist{index}, '.Finalize()']);
        clear(varlist{index});
        display([varlist{index}, ' cleared.']);
    end
end

% Final house keeping
if (~isempty(instrfind))
    fclose(instrfind);
    delete(instrfind);
end

run(['.', filesep(), 'unsetpath.m']);
clear('index', 'varlist', 'instrlist');