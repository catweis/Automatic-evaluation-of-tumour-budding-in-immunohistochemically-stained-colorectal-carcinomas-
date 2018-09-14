function [ObjectData, StatData, picture, varargout] = func_spatialstats(picture, nFigure, Prmetr, vis, varargin)
%calculate basic descriptive values for distribution of brown stained
%objects within one IHC-slide
%   input is a single IHC-image (uint8)

%% input layer
DataIn.picture = picture;

picGray = rgb2gray(picture);
mask = picGray ==0;

for i=1:3
    tPic = picture(:,:,i);
    tPic(mask) =256;
    picture(:,:,i) =tPic;
end

if ~exist('nFigure'), nFigure = 1; end

if exist('vis') ==0
    vis = false;
end

if ~isfield(Prmetr, 'superPixelSize')
   Prmetr.superPixelSize = 10000; 
end
superPixelSize = Prmetr.superPixelSize;

if vis
    figure(nFigure),
    subplot(3,2,1), imagesc(picture), title('Input image')
end

%% prepare the image

tic
if Prmetr.adaptHist

    for i = 1:3
        picture(:,:,i) = adapthisteq(picture(:,:,i));
    end
    
end

if Prmetr.gamma
    
    for i = 1:3
        picture(:,:,i) = imadjust(picture(:,:,i), [], [], 1.5);
    end
    
end

if Prmetr.morphOp
    
    for i=1:3
        picture(:,:,i) = imerode(picture(:,:,i), strel('disk', 10));
    end
    
end

if Prmetr.medFilt
    
    for i =1:3
        picture(:,:,i) = medfilt2(picture(:,:,i), [10 10]);
    end
    
end

if Prmetr.superPixel
   
    [L,N] = superpixels(picture,superPixelSize);
    outputImage = zeros(size(picture),'like',picture);
    idx = label2idx(L);
    numRows = size(picture,1); numCols = size(picture,2);

    for labelVal = 1:N
        redIdx = idx{labelVal};
        greenIdx = idx{labelVal}+numRows*numCols;
        blueIdx = idx{labelVal}+2*numRows*numCols;
        outputImage(redIdx) = mean(picture(redIdx));
        outputImage(greenIdx) = mean(picture(greenIdx));
        outputImage(blueIdx) = mean(picture(blueIdx));
    end    

    picture = outputImage;
    
end

if vis
    subplot(3,2,2), imagesc(picture), title('Input image after adaption')
end
t =toc;
disp(['Image preparation finished in ', num2str(t), 's.'])
%% get the brown objects
tic
[RGB] = func_deconcolour(picture);

if vis
    figure(nFigure),
    subplot(3,2,3), imagesc(RGB.red), colormap 'parula', colorbar,
    title('Color deconvolution')
end

% prepare mask for brown
maskBrown = zeros(size(RGB.red));

if vis
    subplot(3,2,4), hist(RGB.red(:), 100), title('Histogram')
end

if Prmetr.adaptTreshold
    
    [idx,C] = kmeans(RGB.red(:),2, 'Start', [20; 60]); 
    idx = reshape(idx, size(RGB.red));
    
    C = cat(2,C, [1;2]);
    C=  sortrows(C, 1); cIDX = C(2,2);
    
    maskBrown(idx==cIDX) =1;
    
else
    
    maskBrown(RGB.red>=10)=1;
    
end
maskAllTumor = zeros(size(maskBrown));
maskAllTumor(maskBrown==1) =1;
t = toc;
disp(['Positive staining detecion finished in ', num2str(t), 's.'])

%% perform now clustering 
maskTumorTissue = bwlabeln(maskBrown);

% do it
if Prmetr.clusterAnalysis
   
    tic
    maskTumorTissue = func_clusteranalysis(maskTumorTissue, Prmetr);
    t = toc;
    disp(['Cluster analysis finished in ', num2str(t), 's.']) 
    
end

%% now measure (radikaler Umbau)
clusterLabel = unique(maskTumorTissue(:));
tic
clear ObjectData
for iObject = 2: numel(clusterLabel)
    
   %%  
   if sum(sum(clusterLabel(iObject) == maskTumorTissue)) ~= 0
        mask = maskTumorTissue == clusterLabel(iObject);
        ObjectData(iObject-1) = regionprops(double(mask), 'Area', 'Centroid', 'Perimeter', 'BoundingBox');
   end
   
end

%% calculate the distance of every point to its neighbours
if numel(ObjectData) >2
    ObjectData = func_objectdistance(ObjectData, maskBrown, 'Off', 3);

else
    
    for iObj = 1:numel(ObjectData)
        ObjectData(iObj).area = ObjectData(iObj).Area;
        ObjectData(iObj).perimeter = ObjectData(iObj).Perimeter;
        ObjectData(iObj).centroid = ObjectData(iObj).Centroid;
        ObjectData(iObj).neigbDist = NaN;
        ObjectData(iObj).bndBox = ObjectData(iObj).BoundingBox;
    end
    
    ObjectData= rmfield(ObjectData, 'Area');
    ObjectData= rmfield(ObjectData, 'Perimeter');
    ObjectData= rmfield(ObjectData, 'Centroid');
    ObjectData= rmfield(ObjectData, 'BoundingBox');
    
end

%% output layer

for i = 1:numel(ObjectData)  
   tMask = maskTumorTissue==i;
   ObjectData(i).maskBW = logical(tMask); 
end

if vis
    figure(nFigure), subplot(3,2,5), imagesc(maskTumorTissue), colormap parula, colorbar, hold on

    if isfield(ObjectData, 'bndBox')
        for iBox = 1:numel(ObjectData)
            rectangle('Position', ObjectData(iBox).bndBox,'EdgeColor','r')
        end
    end
    
    title('Tumor and tumor buds')
end

if vis
    figure(nFigure), subplot(3,2,6), imagesc(DataIn.picture), colormap parula, colorbar, hold on
    if isfield(ObjectData, 'bndBox')
        for iBox = 1:numel(ObjectData)
            rectangle('Position', ObjectData(iBox).bndBox,'EdgeColor','r')
        end
    end
    title('Tumor and tumor buds')
    hold off
    set(figure(nFigure), 'Position', [100 100 1500 400])
end

StatData = [];
t = toc;
disp(['Object detection finished in ', num2str(t), 's.'])

end

