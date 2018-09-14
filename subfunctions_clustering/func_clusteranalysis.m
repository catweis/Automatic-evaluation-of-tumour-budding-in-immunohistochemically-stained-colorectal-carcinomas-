
function [maskOut] = func_clusteranalysis(maskBrown, Prmetr, varargin)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

%% input layer

if ~isfield(Prmetr, 'clusterBySimilarity')
    Prmetr.clusterBySimilarity = true;
end

if ~isfield(Prmetr, 'clusterByBorderDistance')
    Prmetr.clusterByBorderDistance = true;
end

S = regionprops(logical(maskBrown), 'Area', 'Centroid', 'PixelIdxList');

PixelList = cell(numel(S),1);
points =zeros(numel(S),2);
area = zeros(numel(S),1);
clust1 = area;

for i =1:numel(S) 
    points(i,:) =S(i).Centroid;
    area(i,1) = S(i).Area;
    PixelList{i,1} = S(i).PixelIdxList;
    clust1(i,1) = i;
end

ObjTab0 = table(points,PixelList, area, clust1);

%% cluster the coordinates by distance

if Prmetr.clusterBySimilarity
    
    points(:,4) = [1:size(points,1)];
    %Prmetr.vis = false;
    [ObjTab1] = func_clusterpoints(ObjTab0, Prmetr, maskBrown, Prmetr.cutOffClusterBySimilarity);
    % mount new object

    clusterIDs = unique(ObjTab1.clust2);
    points = zeros(numel(clusterIDs),2);
    clust2 = zeros(numel(clusterIDs),1);
    area = clust2;
    PixelList = cell(numel(clusterIDs),1);

    for i = 1:numel(clusterIDs)
    
        idx = ObjTab1.clust2 ==clusterIDs(i);
    
        points(i,:) = mean(ObjTab1.points(idx,:),1);
        area(i,:) = sum(ObjTab1.area(idx));
    
        List = ObjTab1.PixelList(idx);
        tMask = zeros(size(maskBrown));
    
        for j = 1: sum(idx)
            tMask(List{j}) = 1;
        end
    
        S = regionprops(tMask, 'Area', 'Centroid', 'PixelIdxList');
        PixelList{i,1} =S.PixelIdxList;
    
    end

    clust2 = clusterIDs;
    ObjTab2 = table(points,area, PixelList, clust2);
    nBefore = size(area,1);
    
else
    
   ObjTab2 = ObjTab0;
    
end

%% now cluster the objects cluster-wise by border distance  

if  Prmetr.clusterByBorderDistance
    
    % get the distance matrix 
    distance = func_calcborderdist(ObjTab2, maskBrown);
    
    % calculate
    ObjTab3 = func_clusterobjs(ObjTab2, distance, maskBrown, Prmetr,...
        'non-hierachical');
    
else
    
    ObjTab3 = ObjTab2;
    
end

%% output layer/ draw a mask

if Prmetr.clusterBySimilarity && ~Prmetr.clusterByBorderDistance

    mask = zeros(size(maskBrown));

    for iPoint = 1:size(points,1)
    
        mask(PixelList{iPoint}) = ObjTab3.clust2(iPoint);
    
    end
    
else
    
    mask = zeros(size(maskBrown));

    for iPoint = 1:size(points,1)
    
        mask(PixelList{iPoint}) = ObjTab3.clust3(iPoint);
    
    end
    
end

if Prmetr.vis && Prmetr.clusterByBorderDistance
    
    cmap = prism; cmap(1,:) = 0;
    fig42 = figure();
    
    switch Prmetr.clusterByBorderDistanceMethod
        
        case 'hierachical'
            
            subplot(2,2,1), imagesc(maskBrown), colormap(cmap), hold on
            %gscatter(ObjTab2.points(:,1), ObjTab2.points(:,2), ObjTab2.clust2), hold off
            title(['Before distance clustering; n=', ...
                num2str(numel(unique(ObjTab2.clust2))), ' cluster'])
    
            subplot(2,2,3), hist(hierachicalClusterResult(:))
            subplot(2,2,4), dendrogram(hierachicalClusterResult)
    
            subplot(2,2,2), imagesc(mask), colormap(cmap), hold on
            %gscatter(ObjTab3.points(:,1), ObjTab3.points(:,2),ObjTab3.clust3), hold off
            title(['After distance clustering n=', ...
                num2str(numel(unique(ObjTab3.clust3))), ' cluster'])
            
        case 'non-hierachical'
            
            subplot(1,2,1), imagesc(maskBrown), colormap(cmap),
            title(['Before distance clustering; n=', ...
                num2str(numel(unique(ObjTab2.clust2))), ' cluster'])
             subplot(1,2,2), imagesc(mask), colormap(cmap),
            %gscatter(ObjTab3.points(:,1), ObjTab3.points(:,2),ObjTab3.clust3), hold off
            title(['After distance clustering n=', ...
                num2str(numel(unique(ObjTab3.clust3))), ' cluster'])
    end   
    
    nAfter = numel(unique(ObjTab3.clust3));
    set(fig42,'Name',...
         ['Cluster analysis on border distance (before n=', num2str(nBefore), ...
         ' and after n=', num2str(nAfter),')'],...
         'NumberTitle','off');
     
end

maskOut = mask;

end
