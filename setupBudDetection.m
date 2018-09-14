function setupBudDetection(path2MatConvNet)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% set the paths for subfolders
addpath Classes
addpath subfunctions_clustering
addpath subfunctions_imagePreparation
addpath subfunctions_spatialStatistics
addpath subfunctions_validation

%% activate matconvnet
tPath = cd;
cd(path2MatConvNet)
addpath MatConvNet_ownFunctions
setupMatConvNet
cd(tPath)

end

