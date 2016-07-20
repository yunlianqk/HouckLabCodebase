% Create a sequence of gaussians with inccreasing sigma

% define sampling rate
sampling_rate=64e9;
% load waveform parameters
pulseParam=loadPulseParam(20e-9,5e9,2,80e-9,80e-9);

% each segement has increasing sigma
seqsigma=(20:4:60)*1e-9;

% start from scratch
clear seq
iqseq('delete', [], 'keepOpen', 1);


for i =1:11
    % update pulse width = sigma
    pulseParam.sigma=seqsigma(i);
    % load segements
    iqdownload(SinglePulse(sampling_rate,pulseParam,0),...
            sampling_rate,...
           'channelMapping',[1 0;0 0;0 0;0 0],...%channel 1 I
           'seqmentNumber',i,...
           'keepOpen', 1,...
           'run', 0)
    % setup sequence   
    seq(i).segmentNumber=i;
    seq(i).segmentLoops=1;
    seq(i).segmentAdvance='Auto';
end

iqseq('define',seq,'keepOpen',1,'run',0);
