%This script implements the randomized benchmarking
%Generate the clifford gates needed in this benchmarking sequence;
%seqsubset=floor(2*(linspace(1,8,32)).^2);

seqsubset = 1:100;
softavg = 20;
X180p = 0.568;
dragampx = -0.3;
for counter1 = 1:softavg
    tic
    fprintf(instr.specgen, 'OUTP 1');
    [patseq] = CliffordGroup(seqsubset);
    pause(1);
    for counter2 = 1:length(seqsubset)
        PatternGen(AWGHandle, patseq{counter2});
        [rawi(counter2,:) rawq(counter2,:)] = readIandQ(CardParameters);    
    end
    filti(counter1,:) = mean(rawi(:,1200:3200),2);
    filtq(counter1,:) = mean(rawq(:,1200:3200),2);
    AWG_ArbGaussianPulseGenerator(AWGHandle, [0 X180p], [1 1], dragampx, ones(1,40));
    [oni, onq] = readIandQ(CardParameters);
    fprintf(instr.specgen, 'OUTP 0');
    [offi, offq] = readIandQ(CardParameters);
    exitedi(counter1) = mean(oni(1200:3200));
    exitedq(counter1) = mean(onq(1200:3200));
    groundi(counter1) = mean(offi(1200:3200));
    groundq(counter1) = mean(offq(1200:3200));
    clear rawi rawq 
    save('RBDat.mat', 'filti', 'filtq', 'groundi', 'groundq', 'exitedi', 'exitedq');
    toc
end