function []=CurrentSweep_k2400(Istart,Istop,Istep,k2400)
% 2-Wire current sweep
% Istart - starting current (unit of A)
% Istop - stop current (unit of A)
% Istep - step in current (unit of A)

numPoints=(Istop-Istart)/Istep+1;

fprintf(k2400,'*RST')   % Reset
fprintf(k2400,'*IDN?')  % Identify
idn=fscanf(k2400)       % Display ID

% Configure current sweep
% SOURCE part
fprintf(k2400,':SOUR:FUNC:MODE CURR')       % Current source
fprintf(k2400,':SOUR:CURR:STAR %s', Istart)       % start current
fprintf(k2400,':SOUR:CURR:STOP %s', Istop)      % stop current
fprintf(k2400,':SOUR:CURR:STEP %s', Istep)       % step current
fprintf(k2400,':SOUR:CLE:AUTO ON')          % Enable source auto output-off
fprintf(k2400,':SOUR:CURR:MODE SWE')        % Current sweep mode
fprintf(k2400,':SOUR:SWE:SPAC LIN')         % Linear staircase sweep
fprintf(k2400,':SOUR:DEL:AUTO OFF')         
fprintf(k2400,':SOUR:DEL 0.1')              % 100ms source delay

% SENSE part
fprintf(k2400,':SENS:FUNC "VOLT:DC"')       % Volts sense function 
fprintf(k2400,':SENS:VOLT:PROT:LEV 10')     % Voltage compliance 10V  
fprintf(k2400,':SENS:FUNC:CONC OFF')        % Turn off concurrent functions.
fprintf(k2400,':SENS:VOLT:RANG:AUTO ON')    % Auto voltage range

% FILTER
fprintf(k2400,':SENS:AVER:STAT ON')         % Turn on filter
fprintf(k2400,':SENS:AVER:TCON REP')        % Repetitive type
fprintf(k2400,':SENS:AVER:COUN 100')        % filter count

fprintf(k2400,':SENS:VOLT:NPLC 0.01')           % Power line cycles per integration
fprintf(k2400,':FORM:ELEM:SENS VOLT,CURR')      % Reading the current and voltage
fprintf(k2400,':TRIG:DEL 0')
fprintf(k2400,':SYST:AZER:STAT OFF')            % Disable autozero
fprintf(k2400,':SYST:TIME:RES:AUTO ON')

% ADDED BY JJR for 4pt
fprintf(k2400,':SYST:RSEN ON')

fprintf(k2400,':TRAC:TST:FORM ABS')          % Timestamp format ABSolute: ref to first buffer reading
fprintf(k2400,':TRAC:POIN %f',numPoints)     % Store # reasings in buffer
fprintf(k2400,':TRAC:FEED:CONT NEXT')        % Fill buffer and stop
fprintf(k2400,':TRIG:COUN %f',numPoints)                 % Numb of pulses = number of sweep point
fprintf(k2400,':OUTP ON')                    % Turn on output
fprintf(k2400,':INIT')                       % Trigger sweep

end