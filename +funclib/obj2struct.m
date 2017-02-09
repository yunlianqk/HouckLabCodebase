function s = obj2struct(obj)
% Convert an object to a struct

     s = struct();
     for p = properties(obj)'
         s.(p{:}) = obj.(p{:});
     end
end

