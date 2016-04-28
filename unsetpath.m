% Unset the path environment for the repository

% Remove all subfolders from search path
% The addpath line is a little awkward, but without it a lot of warnings
% will show up
addpath(genpath(pwd));
rmpath(genpath(pwd));