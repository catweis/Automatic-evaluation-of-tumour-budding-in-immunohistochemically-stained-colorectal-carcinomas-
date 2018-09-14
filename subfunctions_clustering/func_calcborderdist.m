function [distance] = func_calcborderdist(ObjTab, maskBrown, Prmetr, varargin)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

%% input-layer
if ~exist('Prmetr')
    Prmetr.vis = false;
    Prmetr.GPU = false;
end

Prmetr.calculationMethod = 'graphical';

%% iterate through all pairs
distance = zeros(size(ObjTab.points,1) , ...
    size(ObjTab.points,1) );

switch Prmetr.calculationMethod
    
    case 'graphical'

        %% graphical calculation
        for iPoint = 1:size(ObjTab.points,1) 

            %% get the temporary reference 
            objRef = zeros(size(maskBrown));
            objRef(ObjTab.PixelList{iPoint}) = 1;
            objRef= logical(objRef);
        
            if Prmetr.GPU
                objRef = gpuarray(logical(objRef));
                objRef = bwdist(objRef);
                objRef = gather(objRef);
            else
                objRef = bwdist(logical(objRef));
            end
    
            %% calculate its minimal border distance to all other
    
            for iOther = 1:size(ObjTab.points,1) 
        
                if iPoint ~= iOther && iPoint<=iOther
        
                %% the other reference 
                %(and all other to this cluster belonging structures) 
                idx = ObjTab.PixelList{iOther};
                distances = objRef(idx);
                tDistance = double(min(distances));
                distance(iPoint,iOther) = tDistance;
        
                if Prmetr.vis
                    figure(42)
                    tMask = objRef; tMask(idx) =0;
                    imagesc(tMask), colormap parula, colorbar, hold on
                    title(['Temporal distance comparison min dist = ',...
                        num2str(tDistance)]);
                    pause(0.1)
                end
       
            end
        
          end
    
        end
    
    case 'calculation'
        
        %% non-graphical calculation
        
        %% calculate 
        tic
        for iPoint = 1:size(ObjTab.points,1) 

            %% get the temporary reference 
            objRef = zeros(size(maskBrown));
            objRef(ObjTab.PixelList{iPoint}) = 1;
            [y,x] = find(objRef > 0);
            objRef= cat(2,y,x);
            %objRef = bwboundaries(objRef);
            %objRef = cell2mat(objRef);
            
            %% calculate its minimal border distance to all other
    
            for iOther = 1:size(ObjTab.points,1) 
        
                if iPoint ~= iOther && iPoint<=iOther
            
                    %% get the coordinates
                    objTemp = zeros(size(maskBrown));
                    objTemp(ObjTab.PixelList{iOther}) = 1;
                     [y,x] = find(objTemp > 0);
                    objTemp= cat(2,y,x);
                  
                    %% get the distance map
                    tDistance = pdist(cat(1,objRef,objTemp));
                    tDistance = squareform(tDistance);
                    
                    %% manipulate it
                    tDistance(logical(eye(size(tDistance)))) =NaN;
                    n = size(objRef,1);
                    tDistance(1:n,1:n) =NaN;
                    m = size(objTemp) + n;
                    tDistance(n+1:m,n+1:m) =NaN;
                    
                    %% retrieve the minimum and fill it
                    tDistance = min(tDistance(:));
                    distance(iPoint,iOther) = tDistance;
                    
                end
            end
        end

end

%% output-layer
distance=distance+distance'-diag([diag(distance)]);
%distance = distance.*2;

end

