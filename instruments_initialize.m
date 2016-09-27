% Initialize instruments
run('.\setpath.m');

% Turn off 32bit IVI-COM warning
warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');

address = struct('rfgen', 23, ...
                 'specgen', 22, ...
                 'logen', 19, ...
                 'pnax', 16, ...
                 'yoko1', 4, ...
                 'triggen', 10, ...
                 'card', 'PXI7::4::0::INSTR', ...
                 'pulsegen1', 'PXI52::15::0::INSTR', ...
                 'pulsegen2', 'PXI50::14::0::INSTR');

global rfgen;
rfgen = E8267DGenerator(address.rfgen);

global specgen;
specgen = E8267DGenerator(address.specgen);

global logen;
logen = E8267DGenerator(address.logen);

global pnax;
pnax = PNAXAnalyzer(address.pnax);

global yoko1;
yoko1 = YOKOGS200(address.yoko1);

global triggen;
triggen = AWG33250A(address.triggen);

global card;
card = U1082ADigitizer(address.card);

global pulsegen1;
pulsegen1 = M9330AWG(address.pulsegen1);

global pulsegen2;
pulsegen2 = M9330AWG(address.pulsegen2);

clear('address');