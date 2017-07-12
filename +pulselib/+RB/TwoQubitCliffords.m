function [Cliffords1, Cliffords2] = TwoQubitCliffords()

    %% Cliffords1 and Cliffords2
    % Contains unitary matrices and prime decompostions of the clifford
    % gates
    
    %% C1genSeqs
    % C1genSeqs contains decomposition of single qubit clifford gates
    % in terms of the following 7 clifford gates
    % Id, X90, X90m, Y90, Y90m, X180, Y180, or
    % C1(1), C1(2), C1(4), C1(5), C1(7), C1(3), C1(6)
    % All decompositions of containing same number of gates are stored

    %% C1mat
    % C1mat contains matrices of all single qubit clifford gates
    
    %% C2Seqs
    % Returns all 11520 two qubit Clifford gates in terms of single 
    % qubit cliffords C1 and entangling gates

    %% C2mat
    % C2mat contains matrices of all two qubit clifford gates
    
    %% Credits
    % Reference: Process verification of two-qubit quantum gates by randomized benchmarking.
    % PRA 87 030301, 2013. https://journals.aps.org/pra/abstract/10.1103/PhysRevA.87.030301
    % Code adapted from BBN codebase
    % https://github.com/BBN-Q/QGL/blob/master/QGL/Cliffords.py
    
    %%
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
    
    function clf = clifford_multiply(c1, varargin)
        % Multiplication table for single qubit cliffords.  Note this assumes c1 is applied first.
        % i.e.  clifford_multiply(c1, c2) calculates c2*c1
        n = length(varargin);
        if n > 0
            tmpMult = C1mat{c1};
            for ind = 1:n
                % Multiply the input clifford matrices one by one to get
                % the resulting matrix
                tmpMult = C1mat{varargin{ind}}*tmpMult;
            end    
            for ind = 1:length(C1mat)
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
    generatorPulses = [1, 2, 4, 5, 7, 3, 6];
    % Get all combinations of generator sequences up to length three
    [x11] = ndgrid(generatorPulses);
    [x21, x22] = ndgrid(generatorPulses);
    [x31, x32, x33] = ndgrid(generatorPulses);
    GenLen = length(generatorPulses);
    GenLenTotal = GenLen + GenLen^2 + GenLen^3;
    generatorSeqs = cell(1, GenLenTotal);
    for i = 1:GenLen^3
        if i <= GenLen
            % Single generator sequences
            generatorSeqs{i} = x11(i);
        end
        if i <= GenLen^2
            % Two-generator sequences
            generatorSeqs{i+GenLen} = [x21(i) ,x22(i)];
        end
        % Three-generator sequences
        generatorSeqs{i+GenLen+GenLen^2} = [x31(i), x32(i), x33(i)];
    end    
    
    % Find the effective unitary for each generator seq
    reducedSeqs = zeros(1, GenLenTotal);
    for ii = 1:GenLenTotal
        tempSeq = num2cell(generatorSeqs{ii});
        reducedSeqs(ii) = clifford_multiply(tempSeq{:});
    end
    
    % Pick first generator sequence (and thus shortest) that gives each Clifford and then
    % also add all those that have the same length
    for x = 1:24
        % First for each of the 24 single-qubit Cliffords find which sequences create them
        allC1Seqs = find(reducedSeqs == x);
        % And the length of the first one for all 24
        minSeqLengths = length(generatorSeqs{allC1Seqs(1)});
        % Find all sequences with the same length as the minimum length
        C1genSeqs = {};
        for seq = allC1Seqs
            if length(generatorSeqs{seq}) == minSeqLengths
                C1genSeqs = [C1genSeqs, generatorSeqs{seq}];
            end    
        end
        % Return clifford gate object
        Cliffords1(x) = pulselib.RB.cliffordGate(x, C1mat{x}, C1genSeqs);
    end

    %%
    C2Seqs = {};
    % The IBM paper has the S-group (rotation n*(pi/3) rotations about the X+Y+Z axis)
    % Sgroup = [C[1], C[17], C[18]]
    % The two qubit Cliffords can be written down as the product of
    % 1. A choice of one of 24^2 C o C single-qubit Cliffords
    % 2. Optionally an entangling gate from CNOT, iSWAP and SWAP
    % 3. Optionally one of 9 S o S gates
    % Therefore, we'll enumerate the two-qubit Clifford as a three tuple ((c1,c2), Entangling, (s1,s2))
    
    %% 1. All pairs of single qubit Cliffords
    [x21, x22] = ndgrid(1:24);
    for ij = 1:length(x21(:))
        C2Seqs{ij}={[x21(ij), x22(ij)],[],[]};
    end  
    
%     [c21, c22, s21, s22] = ndgrid(1:24, 1:24, [1, 17, 18], [1, 17, 18]);
    
%     %% 2. CNOT like class
%     for ik = 1:length(c21(:))
%         C2Seqs {ik+ij} = {[c21(ik), c22(ik)], 'CNOT', [s21(ik), s22(ik)]};
%     end
%     
%     %% 3. iSWAP like class
%     for il = 1:length(c21(:))
%         C2Seqs{ik+ij+il} = {[c21(il), c22(il)], 'iSWAP', [s21(il), s22(il)]};
%     end
%     
%     %% 4. SWAP like class
%     for im = 1:length(x21(:))
%         C2Seqs{ij+ik+il+im} = {[x21(im), x22(im)], 'SWAP', []};
%     end
%     % By now we should have created the genseq for 11520 two-qubit clifford gates
    %% Generate the unitary matrices for all two-qubit clifford gates
    C2mat = cell(length(C2Seqs), 1);
    for ij = 1:length(C2Seqs)
        temp = 1;
        if C2Seqs{ij}{3}
            temp = kron(C1mat{C2Seqs{ij}{3}(1)}, C1mat{C2Seqs{ij}{3}(2)});
        end   
         if C2Seqs{ij}{2}
             temp = temp*entangling_mat(C2Seqs{ij}{2});
         end   
         C2mat{ij} = temp*kron(C1mat{C2Seqs{ij}{1}(1)}, C1mat{C2Seqs{ij}{1}(2)});
         % Return clifford gate object
         Cliffords2(ij) = pulselib.RB.cliffordGate(ij, C2mat{ij}, C2Seqs{ij}, 2);
    end    
    %% Function to calculate unitary matrix for two-qubit gates
    function gatemat = entangling_mat(gate)
        iSWAPmat = [1, 0, 0, 0;...
                    0, 0, 1j, 0;...
                    0, 1j, 0, 0;...
                    0, 0, 0, 1];
        if strcmp(gate, 'CNOT')
            % put X90 gate on the control qubit
            gatemat = iSWAPmat*kron(C1mat{2}, C1mat{1})*iSWAPmat;
        elseif strcmp(gate, 'iSWAP')
            gatemat = iSWAPmat;
        else
            gatemat = iSWAPmat*kron(C1mat{1}, C1mat{4})*iSWAPmat*kron(C1mat{4}, C1mat{1})*iSWAPmat;
        end
    end   
end