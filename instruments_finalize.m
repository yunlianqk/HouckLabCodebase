% Close existing instruments
instrlist = {};
filelist = dir('.');
% Find all class folders in the directory
for file = filelist'
    if file.name(1) == '@'
        instrlist = [instrlist, file.name(2:end)];
    end
end

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
instrlist = instrfind();
if (~isempty(instrlist))
    fclose(instrlist);
    delete(instrlist);
end

run(['.', filesep(), 'unsetpath.m']);
clear('index', 'varlist', 'instrlist', 'filelist', 'file');