% Initialize instruments
% run('.\setpath.m');
addpath('C:\Users\Administrator\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer');
addpath('C:\Users\Administrator\Documents\GitHub\HouckLabMeasurementCode');
             
address = struct('pnax', 'GPIB0::16::INSTR', ...
                 'yoko1', 'GPIB0::2::INSTR', ...
                 'yoko2', 'GPIB0::3::INSTR', ...
                 'yoko3', 'GPIB0::4::INSTR');
 
global pnax;
pnax = PNAXAnalyzer(address.pnax);

global yoko1;
yoko1 = YOKO7651(address.yoko1);

global yoko2;
yoko2 = YOKO7651(address.yoko2);

global yoko3;
yoko3 = YOKOGS200(address.yoko3);

global M8195AWG
M8195AWG = M8195AWG();

% global pxa;
% pxa = PXAAnalyzer(address.pxa);

% global rfgen;
% rfgen = E8267DGenerator(address.rfgen);

% global specgen;
% specgen = E8267DGenerator(address.specgen);

% global logen;
% logen = E8267DGenerator(address.logen);

% global card;
% card = U1084ADigitizer(address.card);
% 
% global pulsegen;
% pulsegen = M9330AWG(address.pulsegen);

% global card;
% card = U1084ADigitizer(address.card);

% global card;
% card = U1082ADigitizer(address.card);

% global triggen;
% triggen = AWG33250A(address.triggen);

clear('address');