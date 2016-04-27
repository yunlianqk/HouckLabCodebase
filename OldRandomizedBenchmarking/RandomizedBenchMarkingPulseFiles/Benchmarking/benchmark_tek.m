function [ Idatafilter Qdatafilter ] = benchmark(instr, CardParameters, SoftAvg)
%BENCHMARK Summary of this function goes here
%   Detailed explanation goes here
for counter = 1:SoftAvg
    [Idata(counter,:,:) Qdata(counter,:,:)] = readIandQ_MultiSegment(instr,CardParameters);
end
    start = 950;
    stop = 4950;
    Idatafilter = squeeze(mean(Idata,1));
    Qdatafilter = squeeze(mean(Qdata,1));
    Idatafilter = mean(Idatafilter,1);
    Qdatafilter = mean(Qdatafilter,1);
    numgates = floor(2*(linspace(1,16,32)).^2);
    figure(133);
    subplot(2,1,1);plot(numgates(1:14), Idatafilter(1:14));%the number of gates is around 100
    subplot(2,1,2);plot(numgates(1:14), Qdatafilter(1:14),'r');
    
end

