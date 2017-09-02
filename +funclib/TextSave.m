function AllFiles = TextSave(dir)
%updated AK 8-14-2017
files = cellstr(ls([dir '*.m']));
% if nargin == 0
% %     files = cellstr(ls('*.m'));
%     files = cellstr(ls('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer\*.m'));
% end
nfiles = length(files);
AllFiles = cell(nfiles,2);

if strcmp(files{1}, '')
    return
else
    for i = 1:nfiles
        fpath = [dir files{i}];
        AllFiles{i,1} = files{i};
%         file = fopen(files{i}, 'rt');
        file = fopen(fpath, 'rt');
        AllFiles{i,2} = fscanf(file,'%c');
        fclose(file);
    end
end