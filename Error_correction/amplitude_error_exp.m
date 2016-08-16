function [ projection ] = amplitude_error_exp(error, num)
    sx = [0, 1 ;1 ,0 ];
    sy = [0, -1j ;1j ,0 ];
    sz = [1, 0 ;0 , -1];
    state = [1;0];
    theta = pi;
    rots = exp(num * log(rotate(theta + error, sy)));
    newstate =  rots * rotate(pi/2, sy) * state;
    projection = newstate(1)^2 -  newstate(2)^2;
end

