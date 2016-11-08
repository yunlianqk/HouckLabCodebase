function [ memLength ] = getMemLength(card,corrparams,startIdx,stopIdx)
% Returns memLength given low pass filter parameters

start = corrparams.offset;
stop = corrparams.offset+corrparams.lengthOfTrace-1;
Fs=1/card.params.sampleinterval;
f = Fs/2*linspace(0,1,(stop-start)/2+1);
cut = 1;
while cut < length(f)-1 && f(cut) < corrparams.LPF
    cut = cut+1;
end

if cut == length(f) - 1
    display('Cannot do this digital filter');
else
      cut+1;
end


memLength=2*length(cut+1:2*cut);


end

