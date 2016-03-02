% Initialize instruments
path = pwd;
addpath(genpath(path));

address = struct('rfgen', 20, ...
                 'specgen', 24, ...
                 'logen', 23, ...
                 'pnax', 16, ...
                 'yoko1', 2, ...
                 'yoko2', 3, ...
                 'yoko3', 4)
%                  'triggen', 9)
%                  'card', 'PXI7::4::0::INSTR', 
%                  'pulsegen', 'PXI50::15::0::INSTR')

global rfgen;
rfgen = E8267DGenerator(address.rfgen);

global specgen;
specgen = E8267DGenerator(address.specgen);

global logen;
logen = E8267DGenerator(address.logen);

global pnax;
pnax = PNAXAnalyzer(address.pnax);

global yoko1;
yoko1 = YOKO7621(address.yoko1);

global yoko2;
yoko2 = YOKO7621(address.yoko2);

global yoko3;
yoko3 = YOKOGS200(address.yoko3);

% global triggen;
% triggen = AWG33250A(address.triggen);

% global card;
% card = U1082ADigitizer(address.card);

% global pulsegen;
% pulsegen = M9330AWG(address.pulsegen);

clear('address', 'path');