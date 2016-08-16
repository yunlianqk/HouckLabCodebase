%Testing rotations
sx = [0, 1 ;1 ,0 ];
sy = [0, -1j ;1j ,0 ];
sz = [1, 0 ;0 , -1];

rotate(pi,sx)
%% Create amplitude error
clear amplitude_error_data
num = 1:20;
for i =  num
    amplitude_error_data(i) = amplitude_error((i-1), -0.0005 * pi);
end
figure()
plot((num-1)*2, amplitude_error_data)
title('amplitude error')
xlabel('num of rotations')
ylabel('Z projection')

%% correct the amplitude error
[ estimated_error, l2_error] = fun_fitting(@amplitude_error,amplitude_error_data, 0,0.5,100)


%%
ax2_data=ax1_data(41,:);
ax2_xaxis=ax1_xaxis;
figure()
plot(ax2_xaxis, ax2_data)
title('amplitude error(measurment)')
xlabel('num of rotations')
ylabel('Z projection')
%%
[ estimated_error, l2_error] = fun_fitting(@amplitude_error,ax2_data,ax2_xaxis/2, 0,1,1000);
%%
for i = 1:length(ax2_xaxis)
     amplitude_corrected(i) = amplitude_error(ax2_xaxis(i)/2,estimated_error);
end
%%
figure
plot(ax2_xaxis,amplitude_corrected,ax2_xaxis,ax2_data)
legend('code','measure')
%% Amplitude error function copied from a paper
num = 1:40;
for i =  num
    amplitude_error_data_paper(i) = amp_error_paper([ 0.5, 0.003 * pi],i); 
end
figure()
plot(num, amplitude_error_data_paper)
title('amplitude error')
xlabel('num of rotations')
ylabel('P(|0>)')
%%
figure
x0 = [0.5,0.010];
x = lsqcurvefit(@amp_error_paper, x0, ax2_xaxis/2,ax2_data);
code_error = amp_error_paper(x, ax2_xaxis/2);
plot(ax2_xaxis, code_error,ax2_xaxis, ax2_data )
legend('corrected','measured')
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

%% Testing tensor product
q1 = [1/sqrt(3);sqrt(2/3)];
kron(q1,q1')
%%
ax4_data = ax4_data';
%%
figure
x0 = [0.5,0.010];
x = lsqcurvefit(@drag_error_paper, x0, ax4_xaxis,ax4_data)
code_error = drag_error_paper(x, ax4_xaxis/2);
plot(ax4_xaxis, code_error,ax4_xaxis,ax4_data )
legend('corrected','measured')

%%
figure()
plot(ax4_xaxis,ax4_data,'k')
%%
ax3_data_norm=(ax3_data-mymin)/(myrange);
ax3_data=ax3_data_norm;
ax3_xaxis=x.numGateVector(1:20);
ax3_yaxis=ampVector(34:162);
figure()
imagesc(ax3_xaxis,ax3_yaxis,ax3_data)
%%
figure()
plot(ax3_data(10,:))
