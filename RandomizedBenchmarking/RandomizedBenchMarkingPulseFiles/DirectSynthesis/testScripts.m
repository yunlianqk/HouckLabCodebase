% JJR April 2016
% script to test the provided RB code

%% generates a random sequence of clifford gates.  breaks it up into separate lists of subsequences
% seqsubset = 1:100;
seqsubset = 4;
X180p = 0.568;
dragampx = -0.3;
[patseq] = CliffordGroup(seqsubset);

%% i want to look directly at the clifford gates rather than the primitives... let's try digging into CliffordGroup code
clear, clc
[cliffs,Clfrdstring]=SingleQubitCliffords();