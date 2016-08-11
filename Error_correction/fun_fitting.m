function [ estimated_error, l2_error] = fun_fitting(fun, data, x_v ,min_v, max_v, num_e)
% input function, error_data, min_v and max_v set the range for error and
% num_e set the num of steps
    delta = abs(max_v-min_v)/num_e;
    l2 = zeros(1,num_e);
    len = length(x_v);
    for i = 1:num_e
        error = delta * i + min_v;
        temp = zeros(1,len);
        for j = 1:len
            temp(j) = fun(x_v(j), error);
        end
        diff = temp - data;

        l2(i) = norm(diff)^2;
    end
    l2_error = min(l2);
    min_ind = find(l2 == l2_error);
    estimated_error = delta * min_ind;
end

