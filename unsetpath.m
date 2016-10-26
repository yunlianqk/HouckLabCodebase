% Unset the path environment for the repository

% Remove all subfolders from search path
warning('off', 'MATLAB:rmpath:DirNotFound');
rmpath(genpath(pwd));
warning('on', 'MATLAB:rmpath:DirNotFound');