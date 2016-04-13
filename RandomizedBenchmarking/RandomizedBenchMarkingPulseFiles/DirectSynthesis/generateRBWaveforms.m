%% generateRBwaveforms - this is top level script to create the waveform files for
% a randomized benchmarking experiment using the M8195A AWG
% April 2016, JJR

%% Pick sizes of RB subsequences to generate
% a vector, each element of which corresponds to the number of clifford
% gates to be used in that waveform. Order is smallest to largest. Only the longest is
% generated, and all the shorter waveforms are just 'subsequences'

% seqsubset = 1:100;
seqsubset= floor(2*(linspace(1,9,32)).^2); %Exponential increment in number of gates

%% Make lists of primitives
% Clifford group will create a cell array, each element of which is a list
% of strings indicating which primitive pulses to do to implement the
% corresponding subsequence.  The correct undo gate has been added.

[patseq] = CliffordGroup(seqsubset);

%% Define basic AWG waveform parameters

samplingRate = 64e9;
% qubitFrequency = 5e9;
% cavityFrequency = 7e9;
% use 0 frequency to get baseband signals for modulating a generator
qubitFrequency = 0;
cavityFrequency = 0;

%% Define universal primitive parameters
% buffers etc.


