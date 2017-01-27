%% Set up some user defined variables
%Sampling Channels
Input_Channel_1 = 'Channel1';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Sampling%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Sampling Properties
SampleRateInHz = 1.6e9; 
PointsPerRecord = 1000;
FullScaleRange = 1;
ACDCCoupling = 1; % AC 0, DC 1, GND 2
Offset = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Triggering%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Triggering Source
Input_Trigger_Source = 'Channel1';

%Trigger Level
Input_Trigger_Level = 0.05;

%Trigger Delay
Input_Trigger_Delay = 0;

%Edge Trigger Type
Input_Trigger_Slope = 1;
%0 = Negative
%1 = Positive

%% Driver Creation
%%%%%%%%%%%%%%%%%%%%%%%Driver Creation Only Done Once%%%%%%%%%%%%%%%%%%%%%%
%{
Process:
You must use a different compiler to do this.
Download a compiler suitable for your system:
http://www.mathworks.com/support/compilers/R2013b/
http://www.mathworks.com/support/compilers/<VERSIOM>/

This used the Microsoft Windows SDK 7.1
If there is an install error, it could be the IOLibs version having a newer
versions of Visual C++ 2010 than the Windows SDK wants, so you must
uninstall them, then install the SDK, then reinstall the new drivers


%}

% Get the resource string from the Agilent VISA ObjectConstructorName and
% verify it is the one used to communicate with the instrument

% agilentVisaInfo = instrhwinfo('visa', 'agilent');
% resourceInfo = agilentVisaInfo.ObjectConstructorName
% 
% IviInfo = instrhwinfo('ivi');
% installedDrivers = IviInfo.Modules
% 
 % Create the MATLAB driver
%makemid('AgMD1', 'AgMD1.mdd', 'ivi-c');

%% Communicate with Instrument
% Initialize
initOptions = 'Simulate=false, DriverSetup= Cal=0, Trace=false, model=M9703A';
visaAddress = 'PXI0::CHASSIS1::SLOT2::FUNC0::INSTR';

myDigitizer = icdevice('AgMD1_win64.mdd', visaAddress, 'optionstring', initOptions);

% Connect to the digitizer using the device object created above
connect(myDigitizer);

%%
% Set the individual channel parameters
invoke(myDigitizer.Configurationchannel, 'configurechannel', Input_Channel_1,...
       FullScaleRange, Offset, ACDCCoupling, true);
   
% Set the acquisition parameters
invoke(myDigitizer.Configurationacquisition, 'configureacquisition',...
       1, PointsPerRecord, SampleRateInHz);

% Set the trigger source, and trigger type
invoke(myDigitizer.Configurationtrigger,'configureedgetriggersource',...
    Input_Trigger_Source,Input_Trigger_Level, Input_Trigger_Slope);

% Calibration
disp('Calibrating...')
invoke(myDigitizer.Instrumentspecificcalibration,...
       'calibrationselfcalibrate',4,0);   % fast cal
disp('Calibration Complete')


%Size waveform arrays as required 
arrayElements =...
    invoke(myDigitizer.WaveformAcquisitionLowLevelAcquisition,...
        'queryminwaveformmemory',16,1,0,PointsPerRecord);

WaveformArrayCh1 = zeros(arrayElements,1);

%% Acquisition

disp('Measuring ...');
    
% Initialize the acquisition
invoke(myDigitizer.WaveformAcquisitionLowLevelAcquisition,...
        'initiateacquisition');
    
% Wait for maximum 1 second for the acquisition to complete,
 try
   invoke(myDigitizer.WaveformAcquisitionLowLevelAcquisition,...
        'waitforacquisitioncomplete', 1000);
catch exception
        % if there is no trigger, send a software trigger
        invoke(myDigitizer.WaveformAcquisitionLowLevelAcquisition,...
        'sendsoftwaretrigger');
        disp('No trigger detected on module 1, forcing software trigger');
        invoke(myDigitizer.WaveformAcquisitionLowLevelAcquisition,...
        'waitforacquisitioncomplete', 1500);
end
    
% Fetch the acquisition waveform data
    
[WaveformArrayCh1,ActualPoints1,FirstValidPoint1,...
        InitialXOffset1,InitialXTimeSeconds1,InitialXTimeFraction1,...
        XIncrement, ScaleFactor, ScaleOffset] = ...
        invoke(myDigitizer.WaveformAcquisitionLowLevelAcquisition,...
        'fetchwaveformint16',Input_Channel_1,arrayElements,WaveformArrayCh1);
   
     
% Convert data to Volts.
disp('Processing data');
for i=1+FirstValidPoint1:FirstValidPoint1+ActualPoints1
   WaveformArrayCh1(i) = WaveformArrayCh1(i) * ScaleFactor + ScaleOffset;
end;

% Display data.
plot(WaveformArrayCh1(1+FirstValidPoint1:FirstValidPoint1+ActualPoints1));
    
disp('Measurement Complete ...');

%% Disconnect
disconnect(myDigitizer);
delete(myDigitizer);
clear myDigitizer;