% Set up the path environment for the repository
% This is important for defining a uniform namespace

% Remove all subfolders from search path
warning('off', 'MATLAB:rmpath:DirNotFound');
rmpath(genpath(pwd));
warning('on', 'MATLAB:rmpath:DirNotFound');
% Add ONLY the top folder
addpath(pwd);
% Add U10xx digitizer driver
addpath(genpath([pwd, '\U10xx_driver']));
addpath([pwd, '\iqtools']);