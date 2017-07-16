function cliffords = SingleQubitCliffords()

    % Returns all 24 single-qubit Clifford gates
    % Each gate contains unitary matrices and prime decompostions
        
    %% C1Seqs
    % C1genSeqs contains decomposition of single qubit clifford gates
    % in terms of the following 7 clifford gates
    % Id, X90, X90m, Y90, Y90m, X180, Y180, or
    % C1(1), C1(2), C1(4), C1(5), C1(7), C1(3), C1(6)
    % All decompositions of containing same number of gates are stored

    %% C1mat
    % C1mat contains matrices of all single qubit clifford gates% Single qubit Pauli matrices

    %% Credits
    % Reference: Process verification of two-qubit quantum gates by randomized benchmarking.
    % PRA 87 030301, 2013. https://journals.aps.org/pra/abstract/10.1103/PhysRevA.87.030301
    % Code adapted from BBN codebase
    % https://github.com/BBN-Q/QGL/blob/master/QGL/Cliffords.py

    %%
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

    function clf = clifford_multiply(c1, varargin)
        % Multiplication table for single qubit cliffords.  Note this assumes c1 is applied first.
        % i.e.  clifford_multiply(c1, c2) calculates c2*c1
        if nargin > 1
            tmpMult = C1mat{c1};
            for ind = 1:length(varargin)
                % Multiply the input clifford matrices one by one to get
                % the resulting matrix
                tmpMult = C1mat{varargin{ind}}*tmpMult;
            end
            checkArray = zeros(1, 24);
            for ind = 1:24
                % Go through all 24 cliffods
                checkArray(ind) = abs(trace(tmpMult'*C1mat{ind}));
            end
            % Find the closest one to the resulting matrix
            [~, clf] = max(checkArray);
        else
            clf = c1;
        end
    end
    % We can usually (without atomic Cliffords) only apply a subset of the single-qubit Cliffords
    % i.e. the pulses that we can apply: Id, X90, X90m, Y90, Y90m, X180, Y180
    generators = [1, 2, 4, 5, 7, 3, 6];
    % Get all combinations of generator sequences up to length three
    [x11] = ndgrid(generators);
    [x21, x22] = ndgrid(generators);
    [x31, x32, x33] = ndgrid(generators);
    GenLen = length(generators);  % GenLen = 24
    GenLenTotal = GenLen + GenLen^2 + GenLen^3;  % GenLenTotal = 24+24^2+24^3
    genProducts = cell(1, GenLenTotal);
    for i = 1:GenLen^3
        if i <= GenLen
            % Single generator sequences
            genProducts{i} = x11(i);
        end
        if i <= GenLen^2
            % Two-generator sequences
            genProducts{i+GenLen} = [x21(i) ,x22(i)];
        end
        % Three-generator sequences
        genProducts{i+GenLen+GenLen^2} = [x31(i), x32(i), x33(i)];
    end

    % Find the effective unitary for each generator seq
    reducedSeqs = zeros(1, GenLenTotal);
    for ii = 1:GenLenTotal
        tempSeq = num2cell(genProducts{ii});
        reducedSeqs(ii) = clifford_multiply(tempSeq{:});
    end
    
    % Pick first generator sequence (and thus shortest) that gives each Clifford
    % Then add all those that have the same length
    for n = 1:24
        % First find which sequences create the Clifford
        allC1Seqs = find(reducedSeqs == n);
        % And the length of the first one for all 24
        minSeqLength = length(genProducts{allC1Seqs(1)});
        % Find all sequences with the same length as the minimum length
        C1Seqs = {};
        for seq = allC1Seqs
            if length(genProducts{seq}) == minSeqLength
                C1Seqs = [C1Seqs, genProducts{seq}];
            end    
        end
        % Return clifford gate object
        cliffords(n) = pulselib.RB.cliffordGate(n, C1mat{n}, C1Seqs);
    end
end