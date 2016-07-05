function [Gatestring,Undo]=UndoGate(seq,Clif,Clfrdstrg)
%only works for one qubit
%Operators
%sm = Destroy_(2);
d=2^1;
sm = [0 1; 0 0];
sp = sm';
sx = sp+sm;
sy = 1i*sp-1i*sm;
sz = [1 0;0 -1];
si = eye(d);

X90p= expm(-1i*sx*pi/4.0);
X90m= expm(1i*sx*pi/4.0);
Y90p= expm(-1i*sy*pi/4.0);
Y90m= expm(1i*sy*pi/4.0);
Xp= expm(-1i*sx*pi/2.0);
Yp= expm(-1i*sy*pi/2.0);
Id = si;

kmax = length(seq);
R = Id;
for k=1:kmax
	test=seq(k);
    if (strcmp(test,'X90pPulse')==1)
        Gate = X90p;
    elseif (strcmp(test,'X90mPulse')==1)
        Gate = X90m;
    elseif  (strcmp(test,'Y90pPulse')==1)
        Gate = Y90p;
    elseif (strcmp(test,'Y90mPulse')==1)
        Gate = Y90m;
    elseif (strcmp(test,'XpPulse')==1)
        Gate = Xp;
    elseif (strcmp(test,'YpPulse')==1)
        Gate = Yp;
    elseif (strcmp(test,'QIdPulse')==1)
        Gate = Id;
    end
	R = Gate*R;
end
Undo =R';
for j=1:24

    if (abs(trace(Clif{j}*R))>=(d-1e-6))
        Gatestring =  Clfrdstrg{j};
    end
end

end
    

    
