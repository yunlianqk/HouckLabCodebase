% This is a template for initializing instruments

% Set path and namespace 
run(['.', filesep(), 'setpath.m']);
% Turn off 32bit IVI-COM warning
warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
% Addresses for equipments
address = struct('rfgen',       'GPIB0::23::0::INSTR', ...
                 'specgen',     'GPIB0::22::0::INSTR', ...
                 'logen',       'GPIB0::19::0::INSTR', ...
                 'pnax',        'GPIB0::16::0::INSTR', ...
                 'yoko1',       'GPIB0::4::0::INSTR', ...
                 'yoko2',       'GPIB0::1::0::INSTR', ...
                 'triggen',     'GPIB0::10::0::INSTR', ...
                 'card',        'PXI7::4::0::INSTR', ...
                 'pulsegen1',   'PXI50::13::0::INSTR', ...
                 'pulsegen2',   'PXI52::14::0::INSTR');

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

global yoko2;
yoko2 = YOKOGS200(address.yoko2);

global triggen;
triggen = AWG33250A(address.triggen);

global card;
card = U1082ADigitizer(address.card);

global pulsegen1;
pulsegen1 = M9330AWG(address.pulsegen1);

global pulsegen2;
pulsegen2 = M9330AWG(address.pulsegen2);
pulsegen2.SyncWith(pulsegen1);

clear('address');