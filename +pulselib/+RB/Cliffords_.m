function cliffmats = Cliffords_(Gens, num_trials, numberofqubits)
% Find the unitary matrices for a Clifford gate
% This does not scale and there is a better way to do this -- in david's paper
    d = 2^numberofqubits;
    si = eye(d);
    currentgate = eye(d);
    numofgen = length(Gens);
    cliffmats = {};
    cliffmats = [cliffmats, si];
    rng(0, 'twister');
    for jj = 1:num_trials
        % Randomly apply generator gates
        temp = floor((numofgen)*rand+1);
        Gen = Gens{temp};
        currentgate = Gen*currentgate;
        % Check if the result is already recorded
        isnew = 1;
        for p = 1:length(cliffmats)
            if (abs(trace(currentgate'*cliffmats{p}))>=(d-1e-6))
                isnew = 0;
            end
        end
        % If it is a new gate, add it to cell array
        if isnew
            cliffmats = [cliffmats, currentgate];
        end
    end

end