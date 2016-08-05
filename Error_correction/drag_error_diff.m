function [ diff ] = drag_error_diff( num, error )
    diff = drag_error(num, error) - drag_error(num, 0);
end

