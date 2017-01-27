function [cliffs, cliffsdecom] = SingleQubitCliffords()

    % run this first as it generatrs the decompoistion of matrices for the
    % clifords and then for each cliford it finds the decomposition.

    % Operators
    sm = [0 1; 0 0];
    sp = sm';
    sx = full(sp+sm);
    sy = full(1i*sp-1i*sm);

    % Pulses %these seven elements can be realized with uw pulses
    X90 = expm(-1i*sx*pi/4.0);  % these two are real generators of the clifford group
    Y90 = expm(-1i*sy*pi/4.0);  % these two are real generators of the clifford group
    Xm90 = expm(1i*sx*pi/4.0);
    Ym90 = expm(1i*sy*pi/4.0);
    Id = [1 0; 0 1];
    X180 = expm(-1i*sx*pi/2.0);
    Y180 = expm(-1i*sy*pi/2.0);

    % getting the cliffords
    Gens = {X90, Y90};
    cliffs = pulselib.RB.Cliffords_(Gens, 200, 1);

    % getting the decomposition
    Gens = {X90, Y90, Xm90, Ym90, Id, X180, Y180};
    Gensstring = {'X90', 'Y90', 'Xm90', 'Ym90', 'Identity','X180', 'Y180'};
    cliffsdecom = {};
    for p = 1:length(cliffs)
        temp = pulselib.RB.GenStrings_(Gens, Gensstring, cliffs{p}, 1);
        cliffsdecom = [cliffsdecom, {temp}];
    end
end