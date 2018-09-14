
classdef CoreData <handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        ObjectData
        image
    end
    
    properties (Access = protected)
        lazy = false
        pMask
    end
    
    properties (Dependent)     
        area
        perimeter
        centroid
        neigbDist
        bndBox
        DataTable
        mask
    end % property-section
    
    methods
        
        %% calucation section----------------------------------------------
        
        function area = get.area(obj)
            
            area = zeros(numel(obj.ObjectData),1);
            
            for i = 1:numel(obj.ObjectData)
                
                area(i,1) = obj.ObjectData(i).area;
                
            end
               
        end
        
        function perimeter = get.perimeter(obj)
            
            perimeter = zeros(numel(obj.ObjectData),1);
            
            for i = 1:numel(obj.ObjectData)
                
                perimeter(i,1) = obj.ObjectData(i).perimeter;
                
            end
               
        end
        
        function neigbDist = get.neigbDist(obj)
            
            neigbDist = zeros(numel(obj.ObjectData),1);
            
            for i = 1:numel(obj.ObjectData)
                
                neigbDist(i,1) = median(obj.ObjectData(i).neigbDist);
                
            end
               
        end
        
        function centroid = get.centroid(obj)
            
            centroid = zeros(numel(obj.ObjectData),2);
            
            for i = 1:numel(obj.ObjectData)
                
                centroid(i,:) = obj.ObjectData(i).centroid;
                
            end
               
        end
        
        function bndBox= get.bndBox(obj)
            
            bndBox = zeros(numel(obj.ObjectData),4);
            
            for i = 1:numel(obj.ObjectData)
                
                bndBox(i,:) = obj.ObjectData(i).bndBox;
                
            end
               
        end
        
        function DataTable = get.DataTable(obj)
            
            DataTable = table(obj.centroid, obj.bndBox, ...
                obj.area, obj.perimeter, obj.neigbDist,...
                'VariableNames',{'centroid' 'bndBox' 'area' 'perimeter'...
                'neigbDist'}); 
        end
        
        %% loading section (only once)------------------------------------- 
        
        function mask =get.mask(obj)
            
            if ~obj.lazy && ~isempty(obj.image) && ~isempty(obj.ObjectData)
                
                 tMask = zeros(size(obj.image,1), size(obj.image,2)); 
            
                for i = 1:numel(obj.ObjectData)
                    tMask(obj.ObjectData(i).maskBW ==1) = i; 
                end
            
                obj.pMask = tMask;
                obj.lazy = true;
                mask = tMask;
                
            else
                
                mask = obj.pMask;
                
            end
        end
            
        %% visualization section (only once)-------------------------------------
        
         function vis(obj)
           
            %% color 
            colorVector = ['m'; 'c'; 'r'; 'g'; 'k'];
            
            %% iterate through it
            iColor =1;
            
            if size(obj.image,3) >1
                image(:,:,1) = rgb2gray(obj.image);
                image(:,:,2) = rgb2gray(obj.image);
                image(:,:,3) = rgb2gray(obj.image);
            else
                image = obj.image;
            end
            
            image = image+10;
            imagesc(image), colormap gray, hold on
            
            for iBox=1:size(obj.bndBox,1)
                
                % plot box
                rectangle('position', [obj.bndBox(iBox,1), obj.bndBox(iBox,2), ...
                    obj.bndBox(iBox,3),obj.bndBox(iBox,4)],...
                     'EdgeColor', colorVector(iColor));
                
                % count
                iColor = iColor +1;
                
                if iColor > length(colorVector)
                    iColor =1;
                end
            end
            
            hold off,
               
        end % function vis
        
    end % methods-section
    
end