function [yval, fs] = iqreaddca(arbConfig, chan, ~, duration, avg, maxAmpl, trigFreq)
% read a waveform from DCA
%
% arguments:
% arbConfig - if empty, use DCA address configured in IQTools config
% chan - list of scope channels to be captured
% trigChan - not used (will always be front panel)
% duration - length of capture (in seconds)
% avg - number of averages (1 = no averaging)
% maxAmpl - amplitude of the signal (will be used to set Y scale)
%           0 means do not set ampltiude
%           -1 means: use maximum amplitude supported by this instrument
%           -2 means: perform autoscale
% trigFreq - trigger frequency in Hz. Zero for once per waveform
%            Non-zero trigger frequency will use PatternLock
%
yval = [];
fs = 1;
if (~exist('arbConfig', 'var'))
    arbConfig = [];
end
arbConfig = loadArbConfig(arbConfig);
if ((isfield(arbConfig, 'isDCAConnected') && arbConfig.isDCAConnected == 0) || ~isfield(arbConfig, 'visaAddrDCA'))
    error('DCA address is not configured, please use "Instrument Configuration" to set it up');
end
f = iqopen(arbConfig.visaAddrDCA);
if (isempty(f))
    return;
end
if (~exist('chan', 'var') || isempty(chan))
    chan = {'1A' '2A'};
end
if (~exist('duration', 'var') || isempty(duration))
    duration = 10e-9;
end
if (~exist('avg', 'var') || isempty(avg) || avg < 1)
    avg = 1;
end
if (~exist('maxAmpl', 'var') || isempty(maxAmpl))
    maxAmpl = -2;        % ampl = -2 means autoscale
end

if (maxAmpl == -2)
    autoScale = 1;
    maxAmpl = 0;
else
    autoScale = 0;
end

if (maxAmpl == -1)
    maxAmpl = 0.8;      % max value supported by 86108B
    dp = strfind(chan, 'DIFF');
    if (~isempty([dp{:}]))
        maxAmpl = 2 * maxAmpl;    % for differential ports, double amplitude
    end
end
if (~exist('trigFreq', 'var') || isempty(trigFreq))
    trigFreq = 0;
end
numChan = length(chan);
xfprintf(f, '*CLS');
% find out which SCPI language to use: flex or old DCA style
flex = 1;
%frame = query(f, ':model? frame');
%if (strncmp(frame, '86100C', 6))
%    flex = 0;
%end
raw_idn = query(f, '*IDN?');
idn = regexp(raw_idn, ',\s*', 'split');
if (strncmp(idn{2}, '86100C', 6))
    flex = 0;
end
%--- some basic setup
xfprintf(f, sprintf(':SYSTem:MODE OSC'));
xfprintf(f, sprintf(':STOP'));
xfprintf(f, sprintf(':TRIG:SOURce:AUTodetect OFF'));
xfprintf(f, sprintf(':TRIG:SOURce FPANEL'));
xfprintf(f, sprintf(':TRIG:PLOC OFF'));

%--- configure the desired channels
for i = 1:numChan
    if (~isempty(strfind(chan{i}, 'DIFF')))
        xfprintf(f, sprintf(':%s:DMODe ON', chan{i}));
    else
        if ((chan{i}(end) == 'A' || chan{i}(end) == 'C') && flex)
            xfprintf(f, sprintf(':DIFF%s:DMODe OFF', chan{i}));
        end
        if (length(chan{i}) <= 2)
            chan{i} = strcat('CHAN', chan{i});
        end
    end
    ampl = maxAmpl(min(i,length(maxAmpl)));
    if (flex)
        if (ampl ~= 0)
            % don't try to set the amplitude higher than the max. supported
            qmax = str2double(query(f, sprintf(':%s:YSCALE? MAX', chan{i})));
            xfprintf(f, sprintf(':%s:YSCALE %g', chan{i}, min(ampl/8, qmax)));
        end
        % Do not set offset to zero. User might want to set it differently
        %    xfprintf(f, sprintf(':%s:YOFFSET %g', chan{i}, 0));
        % Different modules use different ENUMs for setting bandwidth
        % So, let's try out all of them and ignore any errors
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND1', chan{i}(end-1:end)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND2', chan{i}(end-1:end)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND3', chan{i}(end-1:end)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND4', chan{i}(end-1:end)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth HIGH', chan{i}(end-1:end)), 1);
        xfprintf(f, sprintf(':%s:DISP ON', chan{i}));
    else
        if (ampl ~= 0)
            xfprintf(f, sprintf(':%s:SCALE %g', chan{i}(1:5), ampl / 8));
        end
    % Do not set offset to zero. User might want to set it differently
    %    xfprintf(f, sprintf(':%s:OFFSET %g', chan{i}(1:5), 0));
        % Different modules use different ENUMs for setting bandwidth
        % So, let's try out all of them and ignore any errors
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND1', chan{i}(end-1:end-1)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND2', chan{i}(end-1:end-1)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND3', chan{i}(end-1:end-1)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND4', chan{i}(end-1:end-1)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth HIGH', chan{i}(end-1:end-1)), 1);
        xfprintf(f, sprintf(':%s:DISP ON', chan{i}(1:5)));
    end
end

%--- set up timebase and triggering
if (trigFreq ~= 0)
    pattLength = round(trigFreq * duration);
    if (flex)
        % built-in PTB
        xfprintf(f, sprintf(':TIMebase:PTIMebase:RFRequency %.15g', trigFreq));
        xfprintf(f, sprintf(':TIMebase:PTIMEbase:STATe ON'));
        query(f, '*OPC?');
        if (xfprintf(f, sprintf(':TIMebase:PTIMebase:RTReference')))
            return;
        end
        query(f, '*OPC?');
        % slot PTB   ---to be done---
%        xfprintf(f, sprintf(':PTIMebase:RFRequency %.15g', trigFreq));
%        xfprintf(f, sprintf(':PTIMEbase:STATe ON'));
        xfprintf(f, sprintf(':TIMEbase:UNITs SECond'));
        xfprintf(f, sprintf(':TRIG:SOURce FPANEL'));
        xfprintf(f, sprintf(':TRIGger:BWLimit EDGE'));
        xfprintf(f, sprintf(':TRIGger:MODe CLOCk'));
        xfprintf(f, sprintf(':TRIGger:BRATe:AUTodetect OFF'));
        xfprintf(f, sprintf(':TRIGger:PLENgth:AUTodetect OFF'));
        xfprintf(f, sprintf(':TRIGger:DCDRatio:AUTodetect OFF'));
        xfprintf(f, sprintf(':TIMebase:BRATe %.15g', trigFreq));
        xfprintf(f, sprintf(':TRIGger:PLENgth %d', pattLength));
        xfprintf(f, sprintf(':TRIGger:DCDRatio UNITy'));
        xfprintf(f, sprintf(':MEASure:JITTer:DEFine:SIGNal:AUTodetect OFF'));
        xfprintf(f, sprintf(':MEASure:JITTer:DEFine:SIGNal DATA'));
        xfprintf(f, sprintf(':TRIGger:PLOCk ON'));
        query(f, '*OPC?');
    else
        errordlg('PatternLock not yet implemented in legacy DCA mode');
    end
else
    if (flex)
        xfprintf(f, sprintf(':TIMebase:PTIMEbase:STATe OFF'));
        xfprintf(f, sprintf(':PTIMEbase:STATe OFF'));
        xfprintf(f, sprintf(':TIMEbase:UNITs SECond'));
        xfprintf(f, sprintf(':TRIG:BWLimit EDGE'));
    else
        xfprintf(f, sprintf(':TRIG:BWLimit LOW'));
    end
end
xfprintf(f, sprintf(':TRIG:LEVEL %g', 0));
xfprintf(f, sprintf(':TRIG:SLOPe POS'));
xfprintf(f, sprintf(':TIMEbase:REFerence LEFT'));
xfprintf(f, sprintf(':TIMEbase:POS %g', max(24e-9, 0)));
xfprintf(f, sprintf(':TIMEbase:SCALe %g', duration / 10));

if (trigFreq ~= 0)
    numPts = 100000;
    if (flex)
        xfprintf(f, sprintf(':ACQuire:EPATtern ON'));
        xfprintf(f, sprintf(':ACQuire:SPBit:MODe MANual'));
        xfprintf(f, sprintf(':ACQuire:SPBit %d', round(numPts / pattLength)));
        numPts = round(round(numPts / pattLength) * pattLength);
    else
        errordlg('PatternLock not yet implemented in legacy DCA mode');
        error('PatternLock not yet implemented in legacy DCA mode');
    end
else
    if (flex)
        if (xfprintf(f, sprintf(':ACQuire:RSPec RLENgth')))
            return;
        end
        xfprintf(f, sprintf(':ACQuire:RLENgth:MODE MANUAL'));
        xfprintf(f, sprintf(':ACQuire:RLENgth MAX'));
        numPts = str2double(query(f, ':ACQuire:RLENgth?'));
        xfprintf(f, sprintf(':ACQuire:WRAP OFF'));
        xfprintf(f, sprintf(':ACQuire:CDISplay'));
    else
        if (xfprintf(f, sprintf(':CDISplay')))
            return;
        end
        numPts = 16384; % MAX value does not work on old DCA
        %xfprintf(f, sprintf(':ACQuire:POINts MAX'));
        %numPts = str2double(query(f, ':ACQuire:POINts?'));
        xfprintf(f, sprintf(':ACQuire:POINts %d', numPts));
    end
end

if (autoScale)
    xfprintf(f, ':AUTOscale');
    query(f, '*OPC?');
    % set timebase again
    xfprintf(f, sprintf(':TIMEbase:POS %g', max(24e-9, 0)));
    xfprintf(f, sprintf(':TIMEbase:SCALe %g', duration / 10));
end
%--- set up acquisition limits and run

% in pattern lock, acquire a certain number of patterns to avoid "holes" in
% the waveform. Need 12 patterns to guarantee no holes, but experience
% shows that with only 6 patterns, very few holes remain which will be
% interpolated
numPatt = 6;

% there are several cases to be distinguished:
% PatternLock / averaging / flex or legacy
if (avg > 1)
    if (flex)
        if (trigFreq ~= 0)
            xfprintf(f, ':LTESt:ACQuire:CTYPe PATT');
            xfprintf(f, sprintf(':LTESt:ACQuire:CTYPe:PATT %d', numPatt));
        end
        xfprintf(f, sprintf(':ACQuire:SMOOTHING AVER'));
        xfprintf(f, sprintf(':ACQuire:ECOunt %d', avg));
        xfprintf(f, sprintf(':LTESt:ACQuire:CTYPe:WAVeforms %d', avg));
        xfprintf(f, sprintf(':LTESt:ACQuire:STATe ON'));
        xfprintf(f, sprintf(':ACQuire:RUN'));
    else
        xfprintf(f, sprintf(':ACQuire:AVERAGE ON'));
        xfprintf(f, sprintf(':ACQuire:COUNT %d', avg));
        xfprintf(f, sprintf(':ACQuire:RUNTil WAVEforms,%d', avg));
        xfprintf(f, sprintf(':AEEN 1'));
        xfprintf(f, sprintf(':RUN'));
    end
else
    if (flex)
        xfprintf(f, sprintf(':ACQuire:SMOOTHING NONE'));
        if (trigFreq ~= 0)
            xfprintf(f, ':LTESt:ACQuire:CTYPe PATT');
            xfprintf(f, sprintf(':LTESt:ACQuire:CTYPe:PATT %d', numPatt));
            xfprintf(f, sprintf(':LTESt:ACQuire:STATe ON'));
            xfprintf(f, sprintf(':ACQuire:RUN'));
        else
            xfprintf(f, sprintf(':LTESt:ACQuire:STATe OFF'));
            xfprintf(f, sprintf(':ACQuire:SINGLE'));
        end
    else
        xfprintf(f, sprintf(':ACQuire:AVERAGE OFF'));
        xfprintf(f, sprintf(':AEEN 0'));
%        xfprintf(f, sprintf(':SINGLE'));   % with :SINGLE, ESR? does not work
        xfprintf(f, sprintf(':RUN'));
    end
end

%--- wait until capture has completed. Don't use a blocking wait!!
xfprintf(f, '*OPC');
pause(2);
if (trigFreq ~= 0)
    count = round(max(avg, numPatt) * 3) + 10;
else
    count = round(avg * 2) + 10;
end
while count > 0
    esr = str2double(query(f, '*ESR?'));
    if (bitand(esr, 1) ~= 0)
        break;
    end
    pause(1);
    count = count - 1;
end
if (count <= 0)
    errordlg('Scope timeout during waveform capture. Please make sure that the trigger signal is connected to the front panel trigger input');
    return;
end
if (~flex)
    if (strcmp(f.type, 'tcpip'))
        xfprintf(f, ':WAVeform:BYTeorder MSBFIRST');
    else
        xfprintf(f, ':WAVeform:BYTeorder LSBFIRST');
    end
end
yval = zeros(numPts, numChan);

%--- get the waveform from the scope
for i=1:numChan
    if (flex)
        xfprintf(f, sprintf(':WAVeform:SOURce %s', chan{i}));
        xOrig = str2double(query(f, ':WAVeform:YFORmat:XORigin?'));
        xInc  = str2double(query(f, ':WAVeform:YFORmat:XINC?'));
        yOrig = str2double(query(f, ':WAVeform:YFORmat:WORD:ENC:YORigin?'));
        yInc  = str2double(query(f, ':WAVeform:YFORmat:WORD:ENC:YINC?'));
        tmp = binread(f, ':WAVeform:YFORmat:WORD:YDATA?', 'int16');
    else
        xfprintf(f, sprintf(':WAVeform:SOURce %s', chan{i}(1:5)));
        xfprintf(f, sprintf(':WAVeform:FORMAT WORD'));
        tmp = binread(f, ':WAVeform:DATA?', 'int16');
        xOrig = str2double(query(f, ':WAVeform:XORigin?'));
        xInc  = str2double(query(f, ':WAVeform:XINC?'));
        yOrig = str2double(query(f, ':WAVeform:YORigin?'));
        yInc  = str2double(query(f, ':WAVeform:YINC?'));
    end
    % check for overflow
    if (~isempty(find(tmp == 32256, 1)) || ~isempty(find(tmp == 32256, 1)))
        warndlg('Signal exceeds scope range. Consider reducing the scope amplitude scale or insert an attenuator in the signal path', 'Scope Amplitude exceeded', 'replace');
    end
    % replace negative overflow by a negative value
    tmp(tmp == 31744) = -32767;
    % find invalid values ("holes" in PTB) 
    tmp(tmp == 31232) = NaN;
    invidx = find(isnan(tmp));
    if (length(invidx) > 0)
        fprintf('%d invalid samples\n', length(invidx));
        % fill them by interpolation
        xtmp = tmp; xtmp(invidx) = [];
        xaxs = 1:numPts; xaxs(invidx) = [];
        tmp(invidx) = interp1(xaxs, xtmp, invidx);
    end
    % convert to voltage values
    fs = 1 / xInc;
    xval = (1:numPts) * xInc + xOrig;
    yval(:,i) = tmp * yInc + yOrig;
end
if (flex)
    xfprintf(f, sprintf(':ACQuire:SMOOTHING NONE'));
    xfprintf(f, sprintf(':LTESt:ACQuire:STATe OFF'));
else
    xfprintf(f, sprintf(':ACQuire:AVERAGE OFF'));
    xfprintf(f, sprintf(':AEEN 0'));
end
fclose(f);
% if called without output arguments, plot the result
if (nargout == 0)
    figure(151);
    plot(xval, yval, '.-');
    yval = [];
end



function a = binread(f, cmd, fmt)
a = [];
fprintf(f, cmd);
r = fread(f, 1);
if (~strcmp(char(r), '#'))
    error('unexpected binary format');
end
r = fread(f, 1);
nch = str2double(char(r));
r = fread(f, nch);
nch = floor(str2double(char(r))/2);
if (nch > 0)
    a = fread(f, nch, 'int16');
else
    a = [];
end
fread(f, 1); % real EOL




function retVal = xfprintf(f, s, ignoreError)
% Send the string s to the instrument object f
% and check the error status
% if ignoreError is set, the result of :syst:err is ignored
% returns 0 for success, -1 for errors
retVal = 0;
if (evalin('base', 'exist(''debugScpi'', ''var'')'))
    fprintf('cmd = %s\n', s);
end
fprintf(f, s);
result = query(f, ':syst:err?');
if (isempty(result))
    fclose(f);
    errordlg({'The DCA did not respond to a :SYST:ERRor query.' ...
        'Please check that the connection is established and the DCA is responding to commands.'}, 'Error');
    retVal = -1;
    return;
end
if (~exist('ignoreError', 'var') || ignoreError == 0)
    if (~strncmp(result, '0,No error', 10) && ~strncmp(result, '0,"No error"', 12) && ~strncmp(result, '0', 1))
        errordlg({'Instrument returns an error on command:' s 'Error Message:' result}, 'Error');
        retVal = -1;
    end
end
