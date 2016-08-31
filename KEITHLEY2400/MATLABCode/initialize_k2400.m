% Initialize
k2400_address='GPIB0::30::INSTR';
k2400=visa('agilent',k2400_address);

% Set the property values.
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
% Open GPIB object
fopen(k2400); 