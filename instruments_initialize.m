% Initialize instruments
path = pwd;
addpath(genpath(path));

address = struct('rfgen', 23, ...
                 'specgen', 22, ...
                 'logen', 19, ...
                 'pnax', 16, ...
                 'yoko', 4, ...
                 'triggen', 10, ...
                 'card', 'PXI7::4::0::INSTR', ...
                 'pulsegen', 'PXI50::15::0::INSTR');

global rfgen;
rfgen = E8267DGenerator(address.rfgen);

global specgen;
specgen = E8267DGenerator(address.specgen);

global logen;
logen = E8267DGenerator(address.logen);

global pnax;
pnax = PNAXAnalyzer(address.pnax);

global yoko;
yoko = YOKOGS200(address.yoko);

global triggen;
triggen = AWG33250A(address.triggen);

global card;
card = U1082ADigitizer(address.card);

global pulsegen;
pulsegen = M9330AWG(address.pulsegen);

clear('address', 'path');