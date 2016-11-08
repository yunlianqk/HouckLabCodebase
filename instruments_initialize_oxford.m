% Initialize instruments
run(['.', filesep(), 'setpath.m']);

addpath('C:\Users\Administrator\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer');
             
address = struct('pnax',    'GPIB0::16::0::INSTR', ...
                 'yoko1',   'GPIB0::2::0::INSTR', ...
                 'yoko2',   'GPIB0::3::0::INSTR', ...
                 'yoko3',   'GPIB0::4::0::INSTR');
global pnax;
pnax = PNAXAnalyzer(address.pnax);

% global pxa;
% pxa = PXAAnalyzer(address.pxa);

global yoko1;
yoko1 = YOKO7651(address.yoko1);

global yoko2;
yoko2 = YOKO7651(address.yoko2);

global yoko3;
yoko3 = YOKOGS200(address.yoko3);

clear('address');