function [I,V]=FetchCurrentSweep_k2400(Istart,Istop,Istep,k2400)

% Used the serail poll function to wait for SRQ
val = [1];          % 1st instrument in the gpib object, not the gpib add
spoll(k2400,val);    % keep control until SRQ
fprintf(k2400,':TRAC:DATA?')    %Read contents of buffer

data = scanstr(k2400,',','%f'); %data=scanstr(obj,'delimiter','format')

% parse the data & plot
size=round(2*((Istop-Istart)/Istep+1));
I=data(2:2:size,:);
V=data(1:2:size,:);
end