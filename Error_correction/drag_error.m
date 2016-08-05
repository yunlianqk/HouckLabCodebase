function [ projection ] = drag_error( num, error )
    sx = [0, 1 ;1 ,0 ];
    sy = [0, -1j ;1j ,0 ];
    sz = [1, 0 ;0 , -1];    
    theta = pi/2;
    state = [1;0]; % initial state is a ground state
    rots = (rotate(theta, sy) * rotate(error, sz))^num;
    newstate =  rots * state;
    dm  = kron(newstate, newstate');
    projection = trace(sz * dm);
end

