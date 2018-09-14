
%% set the environemt and the MatConvNetPath
clear all
close all
path2MatConvNet = '...';
setupBudDetection(path2MatConvNet)
Prmetr = setPrmetr();

%% load the image
testCore = imread('testCore.tiff');

%% perform analysis
TestCore = main_coreanalysis(testCore, Prmetr);

figure(1), 
subplot(121), imagesc(testCore), title('Input image')
subplot(122), vis(TestCore), title('Results')