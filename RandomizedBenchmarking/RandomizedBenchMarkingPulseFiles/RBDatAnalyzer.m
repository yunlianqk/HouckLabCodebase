
num=10;

for i=1:num
     RBIChan(i,:) = (filti(i,:)-exitedi(i))/(groundi(i)-exitedi(i));
     RBQChan(i,:) = (filtq(i,:)-exitedq(i))/(groundq(i)-exitedq(i));
end

figure;plot(RBIChan');
ExpFuncFit(mean(RBIChan,1),1);