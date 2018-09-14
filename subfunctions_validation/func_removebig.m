function [ObjDat] = func_removebig(ObjDat, DataCore, budSize, vis, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
   
%% input-layer
area = DataCore.area;
bndBox = DataCore.bndBox;
idx = ones(size(area,1),1);
%% iterate through it

if vis
   fig42 = figure(42);
   imagesc(DataCore.image) 
end
    
for i = 1:size(area,1)
       
    if area(i) > budSize(1) && area(i) < budSize(2) % hier ist Musik drin....
       idx(i) =0;
    end
        
    if vis
            
        if idx(i) == 0
                rectangle('Position', bndBox(i,:), 'EdgeColor', 'g');
        else
                rectangle('Position', bndBox(i,:), 'EdgeColor', 'r');
        end
            
    end
        
end

if vis
    set(fig42,'Name',...
        ['Accepted (n=', num2str(sum(idx==0)), ...
        ') and removed bud-proposal (n=', num2str(sum(idx==1)),')'],...
        'NumberTitle','off');
end

%% output layers
idx = logical(idx);
    
area(idx) = [];
ObjDat(idx)= []; 
    
end

