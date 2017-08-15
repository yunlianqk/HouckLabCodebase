function AllFiles = TextSave(dir)
files = cellstr(ls([dir '*.m']));
% if nargin == 0
% %     files = cellstr(ls('*.m'));
%     files = cellstr(ls('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer\*.m'));
% end
nfiles = length(files);
AllFiles = cell(nfiles,2);
for i = 1:nfiles
    AllFiles{i,1} = files{i};
    file = fopen(files{i}, 'rt');
    AllFiles{i,2} = fscanf(file,'%c');
    fclose(file);
end