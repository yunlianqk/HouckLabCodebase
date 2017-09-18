function [] = TekTransferWform2( handle_awg, WformName, AnalogWform, MarkerWform, WformLength)
%UNTITLED2 transfers integer formatted WformDat
%   WformName has to be a string
%   WformDat has to be a vector of 14 bit integers in decimal format
fclose(handle_awg);
% set(handle_awg, 'OutputBufferSize', 1000000);
% set(handle_awg, 'InputBufferSize', 1000000);
 set(handle_awg, 'OutputBufferSize', 20000000);
 set(handle_awg, 'InputBufferSize', 2000000);
fopen(handle_awg);

% if wform of same name exists, it is deleted
fprintf(handle_awg, ['wlis:wave:del "' WformName '"']);

fprintf(handle_awg, ['wlis:wav:new "' WformName '",' num2str(WformLength) ',int']);%the # of points of unconverted Wform shoud be the same as 9000 
fwrite(handle_awg, ['wlis:wav:data "' WformName '",' AnalogWform.Header AnalogWform.Data ';'], 'uint8');
fwrite(handle_awg, ['wlist:waveform:marker:data "' WformName '",' MarkerWform.Header MarkerWform.Data ';'], 'uint8');

end