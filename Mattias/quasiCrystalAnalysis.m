%% change to the data directory
cd /Volumes/ourphoton/Mattias/Data/QUASIwQ

%% plot a nice imagesc 

filename = 'yokoScan_-5020174210538.631_2';

load([filename '.mat']);


figure(33);
imagesc(S21freqvector,params.yoko1vect,S21amp)


%% plot slices

figure(32);
for idx=1:length(params.yoko1vect)
    plot(S21freqvector,S21amp(idx,:))
    waitforbuttonpress;
end

%% figure out Ejmax

omegamax=7.25e9;
