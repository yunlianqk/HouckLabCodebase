function obj = struct2obj(s, obj)

    for field = fieldnames(s)'
        try
            obj.(field{1}) = s.(field{1});
        catch
            warning([field{1}, ' is not a property of ', class(obj)]);
        end
    end
end
