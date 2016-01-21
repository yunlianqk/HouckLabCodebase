function [ my_data ] = read_PNAX(instrhandles)

% Read data from the currently active trace in PNAX

fclose(instrhandles.pnax);
set(instrhandles.pnax,'InputBufferSize',1e6);
set(instrhandles.pnax,'Timeout',30);
fopen(instrhandles.pnax);

% select the active channel and trace
fprintf(instrhandles.pnax, 'SYSTem:ACTive:CHANnel?');
channel = fscanf(instrhandles.pnax, '%d');
fprintf(instrhandles.pnax, 'SYSTem:ACTive:MEASurement?');
measurement = fscanf(instrhandles.pnax, '%s');
% read data
fprintf(instrhandles.pnax,['calc' num2str(channel) ':par:sel ' measurement '']);
fprintf(instrhandles.pnax,['calc' num2str(channel) ':data? fdata']);
data_buffer=fscanf(instrhandles.pnax, '%s');  %the data format???the default format is 19f
my_data=str2num(data_buffer);

fclose(instrhandles.pnax);
set(instrhandles.pnax,'InputBufferSize',40000);
fopen(instrhandles.pnax);

end