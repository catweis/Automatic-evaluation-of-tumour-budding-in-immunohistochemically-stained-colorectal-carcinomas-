function [ObjTab] = func_clusterpoints(ObjTab, Prmetr, maskBrown, cutOff, varargin)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

%% input-layer
if ~exist('cutOff')
    cutOff = 50;
end

points = cat(2,ObjTab.points, ObjTab.area);
nBefore = size(points,1);

%% calculate distance matrix and cluster on that basis
if size(ObjTab,1) ==1
    ObjTab.clust2 = 1;
    return
end

distMatrix  = cat(2, ObjTab.points(:,1), ObjTab.points(:,1), ObjTab.area(:));

hierachicalClusterResult = linkage(distMatrix, 'ward');
hierachicalClusterIncons = inconsistent(hierachicalClusterResult);

if ~Prmetr.fixTresh

    clusterID = cluster(hierachicalClusterResult , 'cutoff',0.05);
    nCluster = length( unique(clusterID) );
    
else
    
    clusterID = cluster(hierachicalClusterResult , 'criterion','distance', 'cutoff',cutOff);

end

nCluster = length( unique(clusterID) );       %# number of clusters found 

%% output layer

ObjTab.clust2 = clusterID;

if Prmetr.vis && exist('maskBrown')
    
    %% prepare the mask
    mask = zeros(size(maskBrown));
    
    for i = 1:size(ObjTab,1)
        
       mask(ObjTab.PixelList{i}) = ObjTab.clust2(i);
        
    end
    
    cmap = prism; cmap(1,:) = 0;
    fig42 = figure();
    subplot(2,2,1), imagesc(maskBrown), colormap(cmap), hold on
    %gscatter(points(:,1), points(:,2), 1:size(points,1)), hold off
    title(['Before point clustering; n=', ...
        num2str(numel(unique(ObjTab.clust1))), ' cluster'])
    
    subplot(2,2,2), imagesc(mask), colormap(cmap), hold on
    %gscatter(points(:,1), points(:,2),clusterID), hold off
    title(['After point clustering n=', ...
        num2str(numel(unique(ObjTab.clust2))), ' cluster'])
    
    subplot(2,2,3), hist(distMatrix(:));
    subplot(2,2,4), dendrogram(hierachicalClusterResult)
    
    nAfter = numel(unique(ObjTab.clust2));
    set(fig42,'Name',...
        ['Cluster analysis on centroid distance (before n=', num2str(nBefore), ...
        ' and after n=', num2str(nAfter),')'],...
        'NumberTitle','off');
    
end

end

