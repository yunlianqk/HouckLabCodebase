function genseq = GenStrings_(Gens, Gensstring, Gate, numberofqubits)
% Find the primitive gate decomposition of a Clifford gate
% Return a cellstr that contains the names of the decomposition gates
% This does not scale and there is a better way to do this -- in david's paper
% The product of the primitive gates and the Clifford gate can differ by a
% factor of -1

    d = 2^numberofqubits;
    inputgate = eye(d);
    numofgen = length(Gens);
    found = 0;
    % Try single generator
    if ~found
        for jj = 1:numofgen
            testgate = Gens{jj}*inputgate;
            if (abs(trace(Gate'*testgate))>=(d-1e-6))
                genseq = {};
                genseq = [genseq, Gensstring{jj}];
                found = 1;
            end
        end    
    end
    % Try two generators
    if ~found
        for jj = 1:numofgen
            for kk = 1:numofgen
                testgate = Gens{kk}*Gens{jj}*inputgate;
                if (abs(trace(Gate'*testgate))>=(d-1e-6))
                    genseq = {};
                    genseq = [genseq, Gensstring{jj}];       	
                    genseq = [genseq, Gensstring{kk}];
                    found = 1;
                end
            end
        end    
    end
    % Try three generators
    if ~found
        for jj = 1:numofgen
            for kk = 1:numofgen
                for ll = 1:numofgen
                    testgate = Gens{ll}*Gens{kk}*Gens{jj}*inputgate;
                    if (abs(trace(Gate'*testgate))>=(d-1e-6))
                        genseq={};
                        genseq = [genseq, Gensstring{jj}]; 
                        genseq = [genseq, Gensstring{kk}];        	
                        genseq = [genseq, Gensstring{ll}];
                        found = 1;
                    end
                end
            end
        end   
    end
    % Failed to find generator-decomposition
    if ~found
       genseq = [genseq, 'none']; 
    end
end