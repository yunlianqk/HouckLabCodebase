function [ projection_amp, projection_drag ] = amp_drag_errors( num, amp_error, drag_error)
    % Test to see if the drag_error will influence the amp_error vice versa 
    sx = [0, 1 ;1 ,0 ];
    sy = [0, -1j ;1j ,0 ];
    sz = [1, 0 ;0 , -1];    
    theta = pi/2;
    state = [1;0];
    rots = (rotate(theta + amp_error, sy) * rotate(drag_error, sz))^num;
    
    newstate_amp =  rots* rotate(pi/2, sy) * state;
    newstate_drag =  rots * state;
    
    projection_amp = norm(newstate_amp(1))^2 -  norm(newstate_amp(2))^2;
    projection_drag = norm(newstate_drag(1))^2 -  norm(newstate_drag(2))^2;

end

