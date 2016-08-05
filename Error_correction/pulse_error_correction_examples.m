%Testing rotations
sx = [0, 1 ;1 ,0 ];
sy = [0, -1j ;1j ,0 ];
sz = [1, 0 ;0 , -1];

rotate(pi,sx)
%% Create amplitude error

num = 1:40;
for i =  num
    amplitude_error_data(i) = amplitude_error(i, 0.01 * pi);
end
figure()
plot(num, amplitude_error_data)
title('amplitude error')
xlabel('num of rotations')
ylabel('Z projection')

%% correct the amplitude error
[ estimated_error, l2_error] = fun_fitting(@amplitude_error,amplitude_error_data, 0,0.5,100)

%%
% Drag error
clear all
num = 1:40;
for i =  num
    drag_error_data(i) = drag_error(i,0.1 * pi);
    no_error_data(i) = drag_error(i, 0);
    diff(i) = drag_error_data(i) - no_error_data(i);
end
figure()
plot(num, drag_error_data)
hold on
plot(num, no_error_data)
title('drag error')
xlabel('num of rotations')
ylabel('Z projection')
figure()
plot(num,diff)
title('drag error')
xlabel('num of rotations')
ylabel('difference in Z projection')



%% correct the drag error
[ estimated_error, l2_error] = fun_fitting(@drag_error,drag_error_data, 0,0.5,100)

%% Correct multiple error
amplitude_error = [0, 0.5];
drag_error = [0, 0.5];
l2_error = 10;
steps = 100;
% error_data = [XXX]
while l2_error> 1e-5
    %Run pi/2 pauli-y pulse for num of times to get the error data
    error_data  = XXXX
    %Correct the amplitude error
    [estimated_amplitude_error, l2_error_amp] = fun_fitting(@amplitude_error,error_data, amplitude_error(1),amplitude_error(2),steps);
    %updae the error range for amplitude error
    amplitude_error(1) = estimated_amplitude_error * 0.9;
    amplitude_error(2) = estimated_amplitude_error * 1.1;
    %Run pi/2 pauli
    [estimated_drag_error, l2_error] = fun_fitting(@drag_error,error_data, drag_error(1),drag_error(2),steps);
    drag_error
end

%% Testing both drag and amp error
amp_error = 0.1 * pi;
drag_error = 0.1 * pi;
for i =  1:40
    [amp_error_data(i), drag_error_data(i)] = amp_drag_errors( i, amp_error, drag_error);
end

%%
figure()
plot(amp_error_data)
hold on
plot(drag_error_data)


