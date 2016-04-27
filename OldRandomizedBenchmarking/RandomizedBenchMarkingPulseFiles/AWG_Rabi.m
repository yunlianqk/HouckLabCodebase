

num_seq = 50;
amp_sweep = linspace(-1,1,num_seq);
dragampx = -0.14;
dragampy = 0.14;
%for counter1 = 1:length(dragamp)
    for counter2 = 1:num_seq
        AWG_ArbGaussianPulseGenerator(AWGHandle, [0 amp_sweep(counter2)], [1 1], dragampx, ones(1,40));
        [rawix(counter2,:), rawqx(counter2,:)] = readIandQ(CardParameters);
        AWG_ArbGaussianPulseGenerator(AWGHandle, [0 amp_sweep(counter2)], [0 0], dragampy, ones(1,40));
        [rawiy(counter2,:), rawqy(counter2,:)] = readIandQ(CardParameters);
    end
    filtix = mean(rawix(:,1200:3200),2);%-mean(rawix(:,100:800),2);
    filtqx = mean(rawqx(:,1200:3200),2);%-mean(rawqx(:,100:800),2);
    filtiy = mean(rawiy(:,1200:3200),2);%-mean(rawiy(:,100:800),2);
    filtqy = mean(rawqy(:,1200:3200),2);%-mean(rawqy(:,100:800),2);
    %clear rawix rawqx
    save('dragdat.mat', 'filtix', 'filtqx', 'filtiy', 'filtqy');
%end

 %filtix = mean(rawix(:,:,1400:4000),3)-mean(rawix(:,:,100:800),3);
 %filtqx = mean(rawqx(:,:,1400:4000),3)-mean(rawqx(:,:,100:800),3);

 %filtiy = mean(rawiy(:,:,1400:4000),3)-mean(rawiy(:,:,100:800),3);
 %filtqy = mean(rawqy(:,:,1400:4000),3)-mean(rawqy(:,:,100:800),3);