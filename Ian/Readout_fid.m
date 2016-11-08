function [ readout_fid_I, readout_fid_Q ] = Readout_fid( SingleShot, Id, X180 )
    
    NN = 20;
    segments = SingleShot.params.segments;
    intdataII = nan(NN * segments, 1);
    intdataQI = nan(NN * segments, 1);

    for numIter = 1:NN
        clear('gateArray');
        gateArray(1,1) = Id;
        SingleShot.qPulse = gateArray;
        % Run experiment
        SingleShot.params.trigPeriod = 25e-6;
        SingleShot.run();
        range = ((numIter - 1) * segments + 1 : numIter * segments);
        intdataII(range) = mean(SingleShot.data.rawdataI{1}(:,500:600),2);
        intdataQI(range) = mean(SingleShot.data.rawdataQ{1}(:,500:600),2);
    end

    intdataI180 = nan(numIter * segments, 1);
    intdataQ180 = nan(numIter * segments, 1);

    for numIter = 1:NN
        clear('gateArray');
        gateArray(1,1) = X180;
        SingleShot.qPulse = gateArray;
        % Run experiment
        SingleShot.params.trigPeriod = 25e-6;
        SingleShot.run();
        range = ((numIter - 1) * segments + 1 : numIter * segments);
        intdataI180(range) = mean(SingleShot.data.rawdataI{1}(:,500:600),2);
        intdataQ180(range) = mean(SingleShot.data.rawdataQ{1}(:,500:600),2);

    end
    
    
    totN = NN * segments;
    
    lower_boundII = min(intdataII);
    lower_boundI180 = min(intdataI180);
    upper_boundII = max(intdataII);
    upper_boundI180 = max(intdataI180);

    lower_boundI = min(lower_boundII,lower_boundI180);
    upper_boundI = max(upper_boundII,upper_boundI180 );

    diff = upper_boundI - lower_boundI ;
    edgeI = lower_boundI: 0.01 * diff: upper_boundI;

    NII = histcounts(intdataII,edgeI);
    NQI = histcounts(intdataQI,edgeI);

    lower_boundQI = min(intdataQI);
    lower_boundQ180 = min(intdataQ180);
    upper_boundQI = max(intdataQI);
    upper_boundQ180 = max(intdataQ180);

    lower_boundQ = min(lower_boundQI,lower_boundQ180);
    upper_boundQ = max(upper_boundQI,upper_boundQ180 );

    diff = upper_boundQ - lower_boundQ;
    edgeQ = lower_boundQ: 0.01 * diff: upper_boundQ;

    NI180 = histcounts(intdataI180,edgeQ);
    NQ180 = histcounts(intdataQ180,edgeQ);
    
    readout_fid_I = max(abs(cumsum(NII) - cumsum(NI180)))/totN;
    readout_fid_Q = max(abs(cumsum(NQI) - cumsum(NQ180)))/totN;
    
% figure(15)
% subplot(2,1,1)
% hold on
% histogram(intdataI180)
% histogram(intdataII)
% xlabel('V_I')
% legend('Identity', 'X180')
% hold off
% subplot(2,1,2)
% hold on
% histogram(intdataQ180)
% histogram(intdataQI)
% xlabel('V_Q')
% legend('Identity', 'X180')
% hold off
%     
% figure(233)
% plot(edgeI(2:end),cumsum(NII)/totN) 
% hold on 
% plot(edgeI(2:end),cumsum(NI180)/totN) 
% title('S curve for I channel')
% 
% figure(234)
% plot(edgeQ(2:end),cumsum(NII)/totN) 
% hold on 
% plot(edgeQ(2:end),cumsum(NI180)/totN) 
% title('S curve for Q channel')  
%     
end

