function [ IData,QData, FilteredData ] = SpecScan_Pulsed( instrhandles, CardParameters, rfparams, specparams, filtparams)
%UNTITLED Spectroscopy scan in pulsed mode
%   rfparams.ConstFreq       rfparams.power
%   specparams.freqvector    specparams.power
%   rfparams.WaitTime
%   filtparams.start filtparams.stop

fprintf(instrhandles.rfgen, ['FREQ ' num2str(rfparams.ConstFreq)]);
fprintf(instrhandles.rfgen, ['POW ' num2str(rfparams.power)]);
fprintf(instrhandles.specgen, ['POW ' num2str(specparams.power)]);
% fprintf(instrhandles.specgen2, ['POW ' num2str(specparams.power)]);
fprintf(instrhandles.logen, ['FREQ ' num2str(rfparams.ConstFreq)]);

for counter = 1:length(specparams.freqvector)
    if counter == 1, tStart = tic; end
    fprintf(instrhandles.specgen, ['FREQ ' num2str(specparams.freqvector(counter))]);
    fprintf(instrhandles.specgen, 'OUTP 1');
%     fprintf(instrhandles.specgen2, ['FREQ ' num2str(specparams.freqvector(counter))]);
%     fprintf(instrhandles.specgen2, 'OUTP 1');    
    pause(rfparams.WaitTime);
    [Ondatai, Ondataq] = readIandQ(CardParameters);
    fprintf(instrhandles.specgen, 'OUTP 0');
%     fprintf(instrhandles.specgen2, 'OUTP 0');
    pause(rfparams.WaitTime);
    [Offdatai, Offdataq] = readIandQ(CardParameters);
    IData(counter,:) = Ondatai-Offdatai;
    QData(counter,:) = Ondataq-Offdataq;
    
    FilteredDataI(counter) = mean(IData(counter,filtparams.start:filtparams.stop),2);
    FilteredDataQ(counter) = mean(QData(counter,filtparams.start:filtparams.stop),2);
    
    if mod(counter,10) == 1
        figure(68);
        subplot(2,1,1);
        imagesc(1:length(IData(1,:)),specparams.freqvector(1:counter),IData);
        subplot(2,1,2);
        imagesc(1:length(QData(1,:)),specparams.freqvector(1:counter),QData);    

        figure(69);
        subplot(2,1,1);
        plot(specparams.freqvector(1:counter),FilteredDataI);
        subplot(2,1,2);
        plot(specparams.freqvector(1:counter),FilteredDataQ);
    end
    if counter == 1
        tElapsed = toc(tStart);
        disp(['Estimated scanning time: ',num2str(tElapsed*length(specparams.freqvector)),' seconds']);
    end
end
    FilteredData.i = FilteredDataI;
    FilteredData.q = FilteredDataQ;
end

