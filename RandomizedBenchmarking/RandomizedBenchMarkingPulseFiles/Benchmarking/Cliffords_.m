function cliffmats=Cliffords_(Gens,num_trials,numberofqubits)
%this does not scale and there is a better way to do this -- in davids
%paper
d = 2^numberofqubits;
si=eye(d);
currentgate= si;
numofgen = length(Gens);
cliffmats={};
cliffmats = [cliffmats, si];
rand('twister',0)
for jj=1:num_trials
    temp = floor((numofgen)*rand+1);
    Gen=Gens{temp};
    currentgate = Gen*currentgate;
    control =0;
    for p=1:length(cliffmats)
        if (abs(trace(currentgate'*cliffmats{p}))>=(d-1e-6))
        control = control + 1;
        end
    end
    if (control==0)
        cliffmats = [cliffmats, currentgate];
    end
    
end

end