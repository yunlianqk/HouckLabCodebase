function [ xInd, yInd, peakVals ] = peakExtractor(data, smoothBool, flipBool)
%peakExtractor will take a chunk of raw data (sweep is on y axis, frequency
%on x) and extract 1 peak from each row
%   Detailed explanation goes here
if flipBool
    data = -1.*data;
end
if smoothBool
    a=smooth(data');
    size(a)
    data = reshape(smooth(data'),size(data,2),size(data,1))';
%     figure();
%     imagesc(data)
end

[peakVals, yInd] = max(data,[],2);
peakVals=-1.*peakVals;


xInd=1:size(data,1);



end

