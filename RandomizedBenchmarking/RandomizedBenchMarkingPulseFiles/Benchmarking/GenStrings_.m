function genseq=GenStrings_(Gens,Gensstring,Gate,numberofqubits)
%this does not scale and there is a better way to do this -- in davids
%paper
d = 2^numberofqubits;
si=eye(d);
inputgate= si;
numofgen = length(Gens);
controlfound =0;
if (controlfound ==0)
    for jj=1:numofgen
    
        testgate = Gens{jj}*inputgate;
        if (abs(trace(Gate'*testgate))>=(d-1e-6))
            genseq={};
            genseq = [genseq, Gensstring{jj}];
            controlfound = 1;
        end
    end    
end
if (controlfound ==0)
    for jj=1:numofgen
        for kk=1:numofgen
            testgate = Gens{kk}*Gens{jj}*inputgate;
            if (abs(trace(Gate'*testgate))>=(d-1e-6))
                genseq={};
                genseq = [genseq, Gensstring{jj}];       	
                genseq = [genseq, Gensstring{kk}];
                controlfound = 1;
            end
        end
    end    
end 

if (controlfound ==0)
    for jj=1:numofgen
        for kk=1:numofgen
            for ll=1:numofgen
                testgate = Gens{ll}*Gens{kk}*Gens{jj}*inputgate;
                if (abs(trace(Gate'*testgate))>=(d-1e-6))
                    genseq={};
                    genseq = [genseq, Gensstring{jj}]; 
                    genseq = [genseq, Gensstring{kk}];        	
                    genseq = [genseq, Gensstring{ll}];
                    controlfound = 1;
                end
            end
        end
    end   
end

if (controlfound ==0)
   genseq = [genseq, 'none']; 
end

end


