% This example will acquire and read a waveform out of an Acqiris
% digitizer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GetStarted8bitSingleSegment.m : MATLAB demo program for Agilent Acqiris 
%                                 Digitizers
%--------------------------------------------------------------------------
% (C) Copyright 2009, 2010-2011 Agilent Technologies, Inc.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Agilent Acqiris - GetStarted8bitSingleSegment');


% Search for instruments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[status nbInstr] = Aq_getNbrInstruments();
if (status ~= 0)
    disp(sprintf('Error in Aq_getNbrInstruments: %d', status));
end

% Use the first digitizer
rscStr  = 'PCI::INSTR0';
options = ''; % No option

% If there is no instrument, simulate one
if nbInstr
    disp(sprintf('%d Agilent Acqiris digitizer(s) found on your PC', nbInstr));
else
    warning('No instrument found! (simulating one)');
    rscStr = 'PCI::DP1400';
    options = 'simulate=true';
end


% Initialization of the instrument %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[status instrID] = Aq_InitWithOptions(rscStr, 0, 0, options);
if (status ~= 0)
    disp(sprintf('Error in Aq_InitWithOptions: %d', status));
end

% Retrieve digitizer position
[status name, serial, bus, slot] = Aq_getInstrumentData(instrID);
if (status ~= 0)
    disp(sprintf('Error in Aq_getInstrumentData: %d', status));
end

% Check instrument class
[status devType] = Aq_getDevType(instrID);
if (status ~= 0)
    disp(sprintf('Error in Aq_getDevType: %d', status));
end
if devType ~= 1 %(see AcqirisDatatypes.h)
    error('This example M-File works only with Acqiris digitizer instrument class.');
end


% Configuration of the digitizer %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Configure timebase
sampInterval = 1e-8;
delayTime = 0.0;
status = AqD1_configHorizontal(instrID, sampInterval, delayTime);
if (status ~= 0)
    disp(sprintf('Error in AqD1_configHorizontal: %d', status));
end

nbrSamples = 1000;
nbrSegments = 1;
status = AqD1_configMemory(instrID, nbrSamples, nbrSegments);
if (status ~= 0)
    disp(sprintf('Error in AqD1_configMemory: %d', status));
end

% Configure vertical settings for channel 1
fullScale = 1.0;
offset = 0.0;
coupling = 3;
bandwidth = 0;
status = AqD1_configVertical(instrID, 1, fullScale, offset, coupling, bandwidth);
if (status ~= 0)
    disp(sprintf('Error in AqD1_configVertical: %d', status));
end

% Configure edge trigger on channel 1
status = AqD1_configTrigClass(instrID, 0, 1, 0, 0, 0, 0);
if (status ~= 0)
    disp(sprintf('Error in AqD1_configTrigClass: %d', status));
end

% Configure the trigger conditions of channel 1 (internal trigger)
trigCoupling = 0;
slope = 0;
level = 20; % In % of vertical full scale when using internal trigger
status = AqD1_configTrigSource(instrID, 1, trigCoupling, slope, level, 0);
if (status ~= 0)
    disp(sprintf('Error in AqD1_configTrigSource: %d', status));
end


% Acquisition of a waveform %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start the acquisition
status = AqD1_acquire(instrID);
if (status ~= 0)
    disp(sprintf('Error in AqD1_acquire: %d', status));
end

% Wait for interrupt to signal the end of acquisition with a timeout of 2 
% seconds. The maximum value is 10 seconds. See 'Reference Manual' for more
% details.
timeout = 2000;
status = AqD1_waitForEndOfAcquisition(instrID, timeout);
if (status ~= 0)
    disp(sprintf('Error in AqD1_waitForEndOfAcquisition: %d', status));
end
if status ~= 0
    status = AqD1_stopAcquisition(instrID);
    error('The acquisition has been stopped - data invalid!');
end


% Readout the waveform %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% An extra space is needed when reading multi-segments
[status segmentPad] = Aq_getInstrumentInfo(instrID, 'TbSegmentPad','integer');
if (status ~= 0)
    disp(sprintf('Error in Aq_getInstrumentInfo: %d', status));
end

% Retrieval of the memory settings
[status nbrSamplesNom, nbrSegmentsNom] = AqD1_getMemory(instrID);
if (status ~= 0)
    disp(sprintf('Error in AqD1_getMemory: %d', status));
end

AqReadParameters.dataType = 0; % 8 bit data
AqReadParameters.readMode = 0; % Single segment read mode
AqReadParameters.firstSegment = 0;
AqReadParameters.nbrSegments = nbrSegmentsNom;
AqReadParameters.firstSampleInSeg = 0;
AqReadParameters.nbrSamplesInSeg = nbrSamplesNom;
AqReadParameters.segmentOffset = nbrSamplesNom;
AqReadParameters.dataArraySize = (nbrSamplesNom + 32);
AqReadParameters.segDescArraySize = 16 * nbrSegmentsNom; % 2*4 bytes for the timestamps and 1*8 bytes for the horPos (see AcqirisDatatypes.h), only for digitizers !
AqReadParameters.flags = 0;
AqReadParameters.reserved = 0;
AqReadParameters.reserved2 = 0.0;
AqReadParameters.reserved3 = 0.0;

% Read the channel 1 waveform
[status dataDesc segDescArray AqDataBuffer] = AqD1_readData(instrID, 1, AqReadParameters);
if (status ~= 0)
    disp(sprintf('Error in AqD1_readData: %d', status));
end

% Convert to volt and display
firstPoint = dataDesc.indexFirstPoint + 1;
lastPoint  = dataDesc.indexFirstPoint + nbrSamplesNom; 
vectorInVolts = cast(AqDataBuffer(firstPoint:lastPoint),'double')*dataDesc.vGain - dataDesc.vOffset;
plot (vectorInVolts);

% Close the instrument
status = Aq_close(instrID);
if (status ~= 0)
    disp(sprintf('Error in Aq_close: %d', status));
end

% Free remaining resources
status = Aq_closeAll();
if (status ~= 0)
    disp(sprintf('Error in Aq_closeAll: %d', status));
end
clear all;
