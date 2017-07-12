function cliffords = SingleQubitCliffords()
    % Returns all 24 single qubit Clifford gates

    % Single qubit Pauli matrices
    pX = [0, 1; 1, 0];
    pY = [0, -1j; 1j, 0];
    pZ = [1, 0; 0, -1];
    pI = eye(2);

    % Basis single-qubit Cliffords with enumeration order following that in BBN
    C1mat = {};
    C1mat(1) = {pI};
    C1mat(2) = {expm(-1j * (pi / 4) * pX)};
    C1mat(3) = {expm(-2j * (pi / 4) * pX)};
    C1mat(4) = {expm(-3j * (pi / 4) * pX)};
    C1mat(5) = {expm(-1j * (pi / 4) * pY)};
    C1mat(6) = {expm(-2j * (pi / 4) * pY)};
    C1mat(7) = {expm(-3j * (pi / 4) * pY)};
    C1mat(8) = {expm(-1j * (pi / 4) * pZ)};
    C1mat(9) = {expm(-2j * (pi / 4) * pZ)};
    C1mat(10) = {expm(-3j * (pi / 4) * pZ)};
    C1mat(11) = {expm(-1j * (pi / 2) * (1 / sqrt(2)) * (pX + pY))};
    C1mat(12) = {expm(-1j * (pi / 2) * (1 / sqrt(2)) * (pX - pY))};
    C1mat(13) = {expm(-1j * (pi / 2) * (1 / sqrt(2)) * (pX + pZ))};
    C1mat(14) = {expm(-1j * (pi / 2) * (1 / sqrt(2)) * (pX - pZ))};
    C1mat(15) = {expm(-1j * (pi / 2) * (1 / sqrt(2)) * (pY + pZ))};
    C1mat(16) = {expm(-1j * (pi / 2) * (1 / sqrt(2)) * (pY - pZ))};
    C1mat(17) = {expm(-1j * (pi / 3) * (1 / sqrt(3)) * (pX + pY + pZ))};
    C1mat(18) = {expm(-2j * (pi / 3) * (1 / sqrt(3)) * (pX + pY + pZ))};
    C1mat(19) = {expm(-1j * (pi / 3) * (1 / sqrt(3)) * (pX - pY + pZ))};
    C1mat(20) = {expm(-2j * (pi / 3) * (1 / sqrt(3)) * (pX - pY + pZ))};
    C1mat(21) = {expm(-1j * (pi / 3) * (1 / sqrt(3)) * (pX + pY - pZ))};
    C1mat(22) = {expm(-2j * (pi / 3) * (1 / sqrt(3)) * (pX + pY - pZ))};
    C1mat(23) = {expm(-1j * (pi / 3) * (1 / sqrt(3)) * (-pX + pY + pZ))};
    C1mat(24) = {expm(-2j * (pi / 3) * (1 / sqrt(3)) * (-pX + pY + pZ))};

    % getting the decomposition
    X90 = expm(-1i*pX*pi/4.0);  % these two are real generators of the clifford group
    Y90 = expm(-1i*pY*pi/4.0);  % these two are real generators of the clifford group
    Xm90 = expm(1i*pX*pi/4.0);
    Ym90 = expm(1i*pY*pi/4.0);
    X180 = expm(-1i*pX*pi/2.0);
    Y180 = expm(-1i*pY*pi/2.0);
    Gens = {X90, Y90, Xm90, Ym90, pI, X180, Y180};
    Gensstring = {'X90', 'Y90', 'Xm90', 'Ym90', 'Identity', 'X180', 'Y180'};
    cliffords = pulselib.RB.cliffordGate(1, pI, 'Identity');
    for ind = 1:length(C1mat)
        decomp = pulselib.RB.GenStrings_(Gens, Gensstring, C1mat{ind}, 1);
        cliffords(ind) = pulselib.RB.cliffordGate(ind, C1mat{ind}, decomp);
    end
end