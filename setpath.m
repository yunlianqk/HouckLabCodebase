% Set up the path environment for the repository
% This is important for defining a uniform namespace

% Remove all subfolders from search path
warning('off', 'MATLAB:rmpath:DirNotFound');
rmpath(genpath(pwd));
warning('on', 'MATLAB:rmpath:DirNotFound');
% Add ONLY the top folder
addpath(pwd);
% Add U10xx digitizer driver
addpath(genpath([pwd, filesep(), 'drivers', filesep(), 'U10xx_driver']));
% Add iqtools
addpath([pwd, filesep(), 'drivers', filesep(), 'iqtools']);
% Add Holzworth driver
addpath([pwd, filesep(), 'drivers', filesep(), 'Holzworth_driver']);
% Add SignalCore driver
switch computer()
    case 'PCWIN64'
        addpath([pwd, filesep(), 'drivers', filesep(), 'SignalCore_driver', ...
                 filesep(), 'x64']);
    case 'PCWIN'
        addpath([pwd, filesep(), 'drivers', filesep(), 'SignalCore_driver', ...
                 filesep(), 'x86']);
    otherwise
end