function [DataOut] = func_objectdistance(DataIn, maskBrown, OnOff, nFigure, varargin)
%calculate the distance of every point to its neighbours
%   applies delaunay triangulation

%% input layer
if ~exist('OnOff'), OnOff = 'Off'; end

%% prepare a vector on basis of detected centroids
for iObject = 1:length(DataIn) 
    xy(iObject,:)=DataIn(iObject).Centroid;
end

%% perform delaunay triangulation to get the neighbours
dtriang = DelaunayTri(xy(:,1),xy(:,2)); 
edgeIndex = edges(dtriang);

switch OnOff
    case 'On'
        figure(nFigure), 
        imagesc(maskBrown), hold on
        scatter(xy(:,1), xy(:,2),150,'MarkerFaceColor', 'white'), hold on
        triplot(dtriang.Triangulation, xy(:,1), xy(:,2), 'LineStyle', '- -', 'color', 'white'), hold off
end

%% calculate the distance between all vertices & plot it if desired
distanceMatrix = [edgeIndex(:,1),edgeIndex(:,2); edgeIndex(:,2), edgeIndex(:,1)];
clear edgeLength
for iCalc = 1:length(distanceMatrix)
    edgeLength(iCalc,1) = ...
        distance(xy(distanceMatrix(iCalc,1),:), xy(distanceMatrix(iCalc,2),:));
end

% mount the distance matrix
distanceMatrix=[distanceMatrix, edgeLength];
distanceMatrix = sortrows(distanceMatrix,1);

% and mount the distance matrix-cell // not very nice looking
pointIdx=1;
DistanceNeigb = cell(size(distanceMatrix,1),1);
for iRow = 1:size(distanceMatrix,1)
    
    currentPoint = distanceMatrix(iRow,1);
    
    if currentPoint ~= pointIdx, pointIdx = pointIdx +1; end
    
    DistanceNeigb{pointIdx}(1, end+1) = distanceMatrix(iRow,3);
    
end
        
%% mount the output element
for iObject = 1:length(DataIn)
    DataOut(iObject).area = DataIn(iObject).Area;
    DataOut(iObject).centroid = DataIn(iObject).Centroid;
    DataOut(iObject).neigbDist = DistanceNeigb{iObject,1};
    DataOut(iObject).perimeter = DataIn(iObject).Perimeter;
    DataOut(iObject).bndBox = DataIn(iObject).BoundingBox;
end

end
