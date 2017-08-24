% Instrument initialization for BF1

run(['.', filesep(), 'setpath.m']);

addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer')

% Turn off 32bit IVI-COM warning
warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');

address = struct('pnax',    'GPIB0::16::INSTR', ...
                 'yoko1',   'GPIB0::7::INSTR', ...
                 'yoko2',   'GPIB0::1::INSTR', ...
                 'yoko3',   'GPIB0::2::INSTR',...
                 'rfgen',   'GPIB0::22::INSTR',...
                 'logen',   'GPIB0::23::INSTR',...
                 'specgen',  'GPIB0::24::INSTR',...
                 'triggen',  'GPIB0::10::INSTR', ...
                 'pxa', 'GPIB0::30::INSTR', ...
                 'card', 'PXI9::0::0::INSTR', ...
                 'pulsegen1', 'PXI16::14::0::INSTR');

global yoko1;
yoko1 = YOKOGS200(address.yoko1);

global yoko2;
yoko2 = YOKOGS200(address.yoko2);

global yoko3;
yoko3 = YOKOGS200(address.yoko3);

global pnax;
pnax = PNAXAnalyzer(address.pnax);

global rfgen;
rfgen = E8267DGenerator(address.rfgen);

global specgen;
specgen = E8267DGenerator(address.specgen);

global logen;
logen = E8267DGenerator(address.logen);

global triggen;
triggen = AWG33250A(address.triggen);

global card;
card = U1084ADigitizer(address.card);

% global rfgen;
% rfgen = E8267DGenerator(address.rfgen);
% 
% global specgen;
% specgen = E8267DGenerator(address.specgen);
% 
% global logen;
% logen = E8267DGenerator(address.logen);
% 
% global triggen;
% triggen = AWG33250A(address.triggen);
% 
clear('address');