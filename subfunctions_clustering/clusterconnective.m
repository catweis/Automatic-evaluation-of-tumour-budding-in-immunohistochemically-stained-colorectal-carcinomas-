function [clusterID] = clusterconnective(ObjTab2, distance, cutOffDistance, cutOffSize)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%% input layer

%% treshold them to allow only the fusion of big with small objects
% and to avoid the fusion of small objects
idxX = find(ObjTab2.area < cutOffSize);
idxY = idxX;
distance(idxY, idxX) =NaN;

%% analyze them
ClustObj = [];
nClust =1;
idxNonClust = 1:size(distance,1);

for iY = 1:size(distance,1)
    
    %% get the values per row
    iX =1;
    values = [];
    while iY > iX
        
     values(1,iX) = distance(iY,iX);
     iX = iX +1;
     
    end
    
    if isempty(values)
        continue
    end
    
    %% analyze them (and check if only small to big and not small to small)
    idx = find(values < cutOffDistance);
    
    if ~isempty(idx)
              
       %% check if there is already such an cluster
       iClust= isclusterd(idx, ClustObj);
       
       %% include the current point 
       idx = cat(2, idx,iY); 
       idxNonClust(idx) = NaN;
       
       %% mount the cluster object accordingly
       if isempty(iClust)
           
            ClustObj(nClust).values = cat(2, values(idx(1:end-1)),0);
            ClustObj(nClust).points = idx;
            ClustObj(nClust).area = ObjTab2.area(idx)';
            nClust =nClust+1;
            
       else
           
           ClustObj(iClust).values = ...
               unique(cat(2, ClustObj(iClust).values , values(idx(1:end-1)),0));
           ClustObj(iClust).points = ...
               unique(cat(2, ClustObj(iClust).points , idx));
           ClustObj(iClust).area = ...
               unique(cat(2, ClustObj(iClust).area , ObjTab2.area(idx)'));
           
       end
        
    end    
    
end

%% output layer
nCluster = size(distance,1)+1;
clusterID = idxNonClust;

for iCluster = 1:numel(ClustObj)

    clusterID(ClustObj(iCluster).points) = nCluster;
    nCluster = nCluster +1;
    
end

clusterID = clusterID';

end

