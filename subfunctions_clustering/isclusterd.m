function [output] = isclusterd(newPoints, ClustObj)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% input layer
output = [];

%%
i =1;
while i <= numel(ClustObj)

    %% set the points
    tempPoints = ClustObj(i).points;
    
    %% test one by one
    for j = 1:length(newPoints)
       
        tRes = ismember(newPoints(j),tempPoints);
        
        if tRes ==1
            break
        end
         
    end
    
    %% decide
    
    if tRes ==1
        
        output = i;
        
    end
        
        i = i+1;
    
end
    
%% output layer


end

