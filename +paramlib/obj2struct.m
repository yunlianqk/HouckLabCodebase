function s = obj2struct(obj)
% Convert an object to a struct

    warning('off', 'MATLAB:structOnObject');
    s = struct(obj);
    warning('on', 'MATLAB:structOnObject');
end

