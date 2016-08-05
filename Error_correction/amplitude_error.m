function [ projection ] = amplitude_error( num, error)
    sx = [0, 1 ;1 ,0 ];
    sy = [0, -1j ;1j ,0 ];
    sz = [1, 0 ;0 , -1];    
    theta = pi;
    state = [1;0];
    rots = rotate(theta + error, sy)^num;
    newstate =  rots* rotate(pi/2, sy) * state;
    projection = newstate(1)^2 -  newstate(2)^2;
end

