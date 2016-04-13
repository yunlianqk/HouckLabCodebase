function [patseq] = CliffordGroup(seqsubset)

QIdPulse = 'QId';
XpPulse = 'Xp';
YpPulse = 'Yp';
XmPulse = 'Xm';
YmPulse = 'Ym';
X90pPulse = 'X90p';
Y90pPulse = 'Y90p';
X90mPulse = 'X90m';
Y90mPulse = 'Y90m';

%% Define Clifford Group
[cliffs,Clfrdstring]=SingleQubitCliffords();
Clfrdstrg={'C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11',...
    'C12','C13','C14','C15','C16','C17','C18','C19','C20','C21','C22','C23','C24'};
for pp=1:24
    Clfrdtemp={};
    for qq=1:length(Clfrdstring{pp})
        if(strcmp(Clfrdstring{pp}{qq},'X90pPulse')==1)
        Test=X90pPulse;
        elseif(strcmp(Clfrdstring{pp}{qq},'X90mPulse')==1)
        Test=X90mPulse;
        elseif(strcmp(Clfrdstring{pp}{qq},'Y90pPulse')==1)
            Test=Y90pPulse;
        elseif(strcmp(Clfrdstring{pp}{qq},'Y90mPulse')==1)
            Test=Y90mPulse;
        elseif(strcmp(Clfrdstring{pp}{qq},'XpPulse')==1)
            Test=XpPulse;
        elseif(strcmp(Clfrdstring{pp}{qq},'YpPulse')==1)
            Test=YpPulse;
        elseif(strcmp(Clfrdstring{pp}{qq},'QIdPulse')==1)
            Test=QIdPulse;   
        end
        Clfrdtemp{qq}=Test;
    end
    Clfrd{pp}=Clfrdtemp;
end

%% Create Clifford Sequence
%seqsubset=floor(2*(linspace(1,9,32)).^2); %Exponential increment in number of gates
%rand('twister',1);

rng('default');
rng('shuffle');

for cindex=1:seqsubset(end)
    temp = randperm(24);
    clfindex = temp(1);
patseqset{cindex} = Clfrd{clfindex};
patstrgset{cindex}=Clfrdstrg{clfindex}; %String of Cliffords
seqstring{cindex}=Clfrdstring{clfindex}; %String of pulses
end
nbrPatterns = length(seqsubset);
for lindex=1:nbrPatterns
    for mindex=1:seqsubset(lindex)
        patseq{lindex}=[patseqset{1:mindex}]; % the square braket make it a whole string 
        patstrg{lindex}=[patstrgset(1:mindex)];
        seq{lindex}=[seqstring(1:mindex)];
    end
end

%% Create and append Undo Pulses
% the undo gate bring the qubit into the ground state
for uindex=1:nbrPatterns
        for pindex=1:size(seq{1,uindex},2)
            seqmat{uindex,pindex}=[seq{1,uindex}{1,pindex}];
            sequence{uindex}=[seqmat{uindex,:}];
        end
        Gatestring{uindex}=UndoGate(sequence{uindex},cliffs,Clfrd);         
end
for uuindex=1:nbrPatterns
    patseq{uuindex}=[patseq{uuindex} Gatestring{uuindex}];
end





