%% generateRBwaveforms - top level script for Randomized Benchmark Experiment
% a randomized benchmarking experiment using the M8195A AWG
% April 2016, JJR
% sets up an RBExperiment object to generate AWG independent waveforms.
% These will be passed to the AWG specific pattern generator for conversion
% to waveforms 
% later versions will also generate arrays of RBExperiment objects, passing in an array
% of some parameter to be varied...

%% Generate RBExperiment Object
clc
rb=RBExperiment

%% Pick sizes of RB subsequences to generate
% a vector, each element of which corresponds to the number of clifford
% gates to be used in that waveform. Order is smallest to largest. Only the longest is
% generated, and all the shorter waveforms are just 'subsequences'

% sequenceList = 1:100;
% sequenceList = floor(2*(linspace(1,9,32)).^2); %Exponential increment in number of gates
rb.sequenceList=2

%% Make lists of primitives
% Clifford group will create a cell array, each element of which is a list
% of strings indicating which primitive pulses to do to implement the
% corresponding subsequence.  The correct undo gate has been added.

rb.generatePrimitives();
rb.primitiveLists{1}

%% Define basic AWG waveform parameters

samplingRate = 64e9;
% qubitFrequency = 5e9;
% cavityFrequency = 7e9;
% use 0 frequency to get baseband signals for modulating a generator
qubitFrequency = 0;
cavityFrequency = 0;

%% Define universal primitive parameters
% buffers etc.

%% array of rb objects?
for ind=1:4
    rbArray(ind)=RBExperiment;
end
