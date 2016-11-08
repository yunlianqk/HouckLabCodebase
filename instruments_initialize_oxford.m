% Initialize instruments
run('.\setpath.m');
addpath('C:\Users\HouckLab\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer');


address = struct('rfgen', 20, ...
                 'specgen', 24, ...
                 'logen', 23, ...
                 'pnax', 16, ...
                 'pxa', 29, ...
                 'yoko1', 2, ...
                 'yoko2', 3, ...
                 'yoko3', 4,...
                 'card', 'PXI3::0::0::INSTR',...;
                 'pulsegen', 'PXI15::14::INSTR');
%                 'card', 'PCI::INSTR0');
%                'triggen', 9)

global rfgen;
rfgen = E8267DGenerator(address.rfgen);

global specgen;
specgen = E8267DGenerator(address.specgen);

global logen;
logen = E8267DGenerator(address.logen);

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

global card;
card = U1084ADigitizer(address.card);

global pulsegen;
pulsegen = M9330AWG(address.pulsegen);

% global card;
% card = U1084ADigitizer(address.card);

% global card;
% card = U1082ADigitizer(address.card);

% global triggen;
% triggen = AWG33250A(address.triggen);

clear('address');