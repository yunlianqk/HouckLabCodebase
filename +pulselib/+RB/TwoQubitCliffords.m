function cliffords = TwoQubitCliffords()

    % Returns all 11520 two-qubit Clifford gates
    % Each gate contains unitary matrices and prime decompostions
    
    %% C1mat
    % C1mat contains matrices of all single qubit clifford gates% Single qubit Pauli matrices
    
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
    C1 = pulselib.RB.SingleQubitCliffords();
    C1mat = cell(24, 1);
    for i = 1:24
        C1mat{i} = C1(i).unitary;
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
    
    [c21, c22, s21, s22] = ndgrid(1:24, 1:24, [1, 17, 18], [1, 17, 18]);

    %% 2. CNOT like class
    for ik = 1:length(c21(:))
        C2Seqs {ik+ij} = {[c21(ik), c22(ik)], 'CNOT', [s21(ik), s22(ik)]};
    end
    
    %% 3. iSWAP like class
    for il = 1:length(c21(:))
        C2Seqs{ik+ij+il} = {[c21(il), c22(il)], 'iSWAP', [s21(il), s22(il)]};
    end

    %% 4. SWAP like class
    for im = 1:length(x21(:))
        C2Seqs{ij+ik+il+im} = {[x21(im), x22(im)], 'SWAP', []};
    end
    % By now we should have created the genseq for 11520 two-qubit clifford gates
    %% Generate the unitary matrices for all two-qubit clifford gates
    C2mat = cell(length(C2Seqs), 1);
    for i = 1:length(C2Seqs)
        temp = eye(4);
        if C2Seqs{i}{3}
            temp = kron(C1mat{C2Seqs{i}{3}(1)}, C1mat{C2Seqs{i}{3}(2)});
        end
        if C2Seqs{i}{2}
         temp = temp*entangling_mat(C2Seqs{i}{2});
        end
        C2mat{i} = temp*kron(C1mat{C2Seqs{i}{1}(1)}, C1mat{C2Seqs{i}{1}(2)});
        % Return clifford gate object
        cliffords(i) = pulselib.RB.cliffordGate(i, C2mat{i}, C2Seqs{i}, 2);
    end
    %% Function to calculate unitary matrix for two-qubit gates
    function gatemat = entangling_mat(gate)
        % Decomposition taken from N. Schuch and J. Siewert, Phys. Rev. A 67, 032301 (2003).
        % Ignoring all single qubit gates in the start and end of the entangling gate

        iSWAPmat = [1, 0, 0, 0; ...
                    0, 0, 1j, 0; ...
                    0, 1j, 0, 0; ...
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