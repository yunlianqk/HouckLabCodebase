function [cliffs,cliffsdecom]=SingleQubitCliffords()

%run this first as it generatrs the decompoistion of matrices for the
%clifords and then for each cliford it finds the decomposition.

%Operators
%sm = Destroy_(2);
sm =[0 1; 0 0];
sp = sm';
sx = full(sp+sm);
sy = full(1i*sp-1i*sm);
sz = [1 0;0 -1];

%Pulses %these seven elements can be realized with uw pulses
X90p= expm(-1i*sx*pi/4.0);  % these two are real generators of the clifford group
Y90p= expm(-1i*sy*pi/4.0);  % these two are real generators of the clifford group
X90m= expm(1i*sx*pi/4.0);
Y90m= expm(1i*sy*pi/4.0);
Id = [1 0; 0 1];
Xp= expm(-1i*sx*pi/2.0);
Yp= expm(-1i*sy*pi/2.0);

%getting the cliffords
Gens = {X90p,Y90p};
cliffs =Cliffords_(Gens,200,1);
length(cliffs);

%getting the decomposition  % the decomposition is in terms of following uw
%pulses 
Gens = {X90p,Y90p, X90m, Y90m, Id, Xp, Yp};
Gensstring ={'X90pPulse', 'Y90pPulse', 'X90mPulse', 'Y90mPulse','QIdPulse','XpPulse', 'YpPulse'};
cliffsdecom={};
for p=1:length(cliffs)
    temp = GenStrings_(Gens,Gensstring,cliffs{p},1);
    %[p,temp]
    cliffsdecom= [cliffsdecom, {temp}];
end

cliffsdecom;

end