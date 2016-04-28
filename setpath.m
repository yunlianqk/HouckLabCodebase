% Set up the path environment for the repository
% This is important for defining a uniform namespace

% Remove all subfolders from search path
% The addpath line is a little awkward, but without it a lot of warnings
% will show up
addpath(genpath(pwd));
rmpath(genpath(pwd));

% Add ONLY the top folder
addpath(pwd);