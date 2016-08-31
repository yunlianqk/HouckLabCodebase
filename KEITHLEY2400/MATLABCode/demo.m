%% Close and delete
fclose(k2400);
delete(k2400);
clear k2400;
clear out;
%% Initialize
k2400 = gpib('ni', 0, 30);

%% Set the property values.
set(k2400, 'BoardIndex', 0);
set(k2400, 'ByteOrder', 'littleEndian');
set(k2400, 'BytesAvailableFcn', '');
set(k2400, 'BytesAvailableFcnCount', 48);
set(k2400, 'BytesAvailableFcnMode', 'eosCharCode');
set(k2400, 'CompareBits', 8);
set(k2400, 'EOIMode', 'on');
set(k2400, 'EOSCharCode', 'LF');
set(k2400, 'EOSMode', 'read&write');
set(k2400, 'ErrorFcn', '');
set(k2400, 'InputBufferSize', 2000);
set(k2400, 'Name', 'GPIB0-30');
set(k2400, 'OutputBufferSize', 2000);
set(k2400, 'OutputEmptyFcn', '');
set(k2400, 'PrimaryAddress', 30);
set(k2400, 'RecordDetail', 'compact');
set(k2400, 'RecordMode', 'overwrite');
set(k2400, 'RecordName', 'record.txt');
set(k2400, 'SecondaryAddress', 0);
set(k2400, 'Tag', '');
set(k2400, 'Timeout', 10);
set(k2400, 'TimerFcn', '');
set(k2400, 'TimerPeriod', 1);
set(k2400, 'UserData', []);

if nargout > 0 
    out = [k2400]; 
end
%% Open GPIB object
fopen(k2400);            
%% Current Sweep

Istart = 1E-6;
Istop = 5E-6;
Istep = 0.1E-6;
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

fprintf(k2400,':TRAC:TST:FORM ABS')          % Timestamp format ABSolute: ref to first buffer reading
fprintf(k2400,':TRAC:POIN %f',numPoints)     % Store # reasings in buffer
fprintf(k2400,':TRAC:FEED:CONT NEXT')        % Fill buffer and stop
fprintf(k2400,':TRIG:COUN %f',numPoints)                 % Numb of pulses = number of sweep point
fprintf(k2400,':OUTP ON')                    % Turn on output
fprintf(k2400,':INIT')                       % Trigger sweep

%% Fetch data

% Used the serail poll function to wait for SRQ
val = [1];          % 1st instrument in the gpib object, not the gpib add
spoll(k2400,val);    % keep control until SRQ
fprintf(k2400,':TRAC:DATA?')    %Read contents of buffer

A = scanstr(k2400,',','%f');    %A = scanstr(obj,'delimiter','format')
%%
% parse the data & plot
Curr=A(2:2:2*numPoints,:);
Volts=A(1:2:2*numPoints,:);

figure(1);
plot(Curr,Volts,':bo','LineWidth',0.5,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','r',...
                'MarkerSize',5)
xlabel('Source-current (A)'),ylabel('Measured-volts(V)')
title('Keithley 2400: Sweeps I (0.1mA-1mA) & Measure V');
%% CLEAR BUFFER
fprintf(k2400,':TRAC:FEED:CONT NEVER'); %necessary before clearing buffer, avoid +800 error
fprintf(k2400,':TRAC:CLE'); %clear buffer
%% RESET 
% reset all the registers & clean up
% if the registers are not properly reset, 
% subsequent runs will not work!
fprintf(k2400,'*RST');
fprintf(k2400,':*CLS ');
fprintf(k2400,':*SRE 0');
% make sure STB bit is 0
STB = query(k2400, '*STB?');
fclose(k2400);
delete(k2400)
clear k2400



