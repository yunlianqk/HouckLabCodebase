figure(1)
ax2_data=ax1_data(41,:);
ax2_xaxis=ax1_xaxis;
%%
plot(ax2_xaxis,ax2_data)

%%
figure
plot(ax2_xaxis,ax2_data)
hold on
[estimated_error, l2_error] = fun_fitting(@amplitude_error,ax2_data,ax2_xaxis, 0,0.5,100)
len = length(ax2_xaxis);
for i =  1:len
    amplitude_error_data(i) = amplitude_error(ax2_xaxis(i), 0.01 * pi);
end
plot(ax2_xaxis, amplitude_error_data)
%%
figure
plot(ax2_xaxis,ax2_data)
%%
hold on
num = 1:40;
for i =  num
    amplitude_error_data(i) = amplitude_error(i, 0.01 * pi);
end
plot(num, amplitude_error_data)
title('amplitude error')
xlabel('num of rotations')
ylabel('Z projection')
