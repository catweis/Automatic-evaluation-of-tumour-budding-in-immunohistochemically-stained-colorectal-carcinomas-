function Prmetr = setPrmetr()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% image-preparation in general 
Prmetr.adaptHist = false;
Prmetr.medFilt = true;
Prmetr.gamma = true;
Prmetr.morphOp = false;
Prmetr.superPixel = true;
Prmetr.superPixelSize = 25000;

%% staining detection
Prmetr.adaptTreshold = true;

%% proposal generation and definition
Prmetr.clusterAnalysis = true;

Prmetr.clusterBySimilarity = true;
Prmetr.fixTresh = true;
Prmetr.cutOffClusterBySimilarity = 10;

Prmetr.clusterByBorderDistance = true;
Prmetr.clusterByBorderDistanceMethod = 'non-hierachical';
Prmetr.cutOffClusterByBorderDistance = 25;
Prmetr.GPU = true;

%% proposal validation
% by morphology
Prmetr.adaptSize = true;
Prmetr.budSize = [20 4500];

%by CNN
Prmetr.adaptImage = true;
Prmetr.bndBoxSizeFactor = 2;
Prmetr.CNNRounds = 4;
Prmetr.targetImage = 'modified';

%% visualization
Prmetr.vis = false;

end

