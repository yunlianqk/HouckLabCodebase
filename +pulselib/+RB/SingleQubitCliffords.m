function cliffords = SingleQubitCliffords()
    % Returns all 24 single qubit Clifford gates

    % Operators
    sm = [0 1; 0 0];
    sp = sm';
    sx = full(sp+sm);
    sy = full(1i*sp-1i*sm);

    % Primitive gates
    X90 = expm(-1i*sx*pi/4.0);  % these two are real generators of the clifford group
    Y90 = expm(-1i*sy*pi/4.0);  % these two are real generators of the clifford group
    Xm90 = expm(1i*sx*pi/4.0);
    Ym90 = expm(1i*sy*pi/4.0);
    Id = [1 0; 0 1];
    X180 = expm(-1i*sx*pi/2.0);
    Y180 = expm(-1i*sy*pi/2.0);

    % getting the cliffords
    clfmat = pulselib.RB.Cliffords_({X90, Y90}, 200, 1);

    % getting the decomposition
    Gens = {X90, Y90, Xm90, Ym90, Id, X180, Y180};
    Gensstring = {'X90', 'Y90', 'Xm90', 'Ym90', 'Identity','X180', 'Y180'};
    cliffords = pulselib.RB.cliffordGate(1, Id, 'Identity');
    for ind = 1:length(clfmat)
        decomp = pulselib.RB.GenStrings_(Gens, Gensstring, clfmat{ind}, 1);
        cliffords(ind) = pulselib.RB.cliffordGate(ind, clfmat{ind}, decomp);
    end
end