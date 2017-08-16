funclib.clear_local_variables()

a = 1;
b = 2;
c = [1,2,3,4];
d = 'Hello World';

saveFolder = 'C:\Users\BFG\Documents\Mattias\tunableDimer\SpecScans_081417';
saveName = 'junk.mat';

savePath = [saveFolder saveName];

% filePath = [mfilename('fullpath') '.m']
filePath = mfilename('fullpath')

% funclib.save_all(savePath)
funclib.save_all(savePath, filePath)


test = load(savePath);
disp(test.save_variables.d)
disp(test.AllFiles);