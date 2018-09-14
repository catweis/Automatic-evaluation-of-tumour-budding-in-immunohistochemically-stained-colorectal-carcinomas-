function [ObjTab3] = func_clusterobjs(ObjTab2, distance, maskBrown, Prmetr, method, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% input layer
if exist('method') ==0
    method ='hierachical';
end

cutOff = Prmetr.cutOffClusterByBorderDistance;
cutOffArea = Prmetr.budSize(2);

%% calculate
switch method
    
    case 'hierachical'
       
        %% perform hierachical clustering
        hierachicalClusterResult =  linkage(distance, 'ward');
        %cutOff = round(0.1*max(hierachicalClusterResult(:,end)));  
        clusterID = cluster(hierachicalClusterResult,  'cutoff',cutOff, ...
            'criterion','distance');

        case 'non-hierachical'
        
        %% perform non-hierachical clustering
        clusterID = clusterconnective(ObjTab2, distance, cutOff, cutOffArea);

end
              
%% mount together
ObjTab2.clust3 = clusterID;

clusterIDs = unique(ObjTab2.clust3);
points = zeros(numel(clusterIDs),2);
clust3 = zeros(numel(clusterIDs),1);
area = clust3;
PixelList = cell(numel(clusterIDs),1);

for i = 1:numel(clusterIDs)
    
     idx = ObjTab2.clust3 ==clusterIDs(i);
    
     points(i,:) = mean(ObjTab2.points(idx,:),1);
     area(i,:) = sum(ObjTab2.area(idx));
    
      List = ObjTab2.PixelList(idx);
      tMask = zeros(size(maskBrown));
    
      for j = 1: sum(idx)
          tMask(List{j}) = 1;
      end
    
         S = regionprops(tMask, 'Area', 'Centroid', 'PixelIdxList');
         PixelList{i,1} =S.PixelIdxList;
end

clust3 = clusterIDs;

%% output layer



%ObjTab3 = table(points,area, PixelList, clust3);
ObjTab3 = ObjTab2;

end

