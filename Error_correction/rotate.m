function [ state ] = rotate( theta, s )
    state = expm(-1j * s * theta/2);
end

