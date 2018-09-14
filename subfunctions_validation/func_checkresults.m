function [ObjectDataOut] = func_checkresults(ObjectData, core, BudNet, vis, bndBoxSizeFactor, CNNRounds, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% input layers
if ~exist('BudNet') || isempty(BudNet)
   load('subfunctions_validation/BudNet.mat');
end

if ~exist('vis')
    vis = false;
end

if ~exist('bndBoxSizeFactor')
   bndBoxSizeFactor = 1.75;
end

if ~exist('CNNRounds')
    CNNRound = 2;
end

ObjectDataIn = ObjectData;
treshValue = 0.75;

if size(ObjectData,1) == 0 || size(ObjectData,2) == 0
    ObjectDataOut = ObjectData;
    return
end

%% analyze it
for iRound = 1:CNNRounds

    %% to avoid un-necessary calculations
    if size(ObjectData,1) == 0 ||  size(ObjectData,2) == 0
        continue
    end
    
    %% crop all images 

    data = single(zeros(100,100, 3, numel(ObjectData)));
    adaptBndBox = zeros(numel(ObjectData),4);
    
    for iObj = 1:numel(ObjectData)
    
        %% adapt the bnd -box
        bndBox = ObjectData(iObj).bndBox;
        bndBox(1) = bndBox(1) + 0.5*bndBox(3);
        bndBox(2) = bndBox(2) + 0.5*bndBox(4);
        bndBox(3) = bndBox(3) * bndBoxSizeFactor^(iRound-1);
        bndBox(4) = bndBox(4) * bndBoxSizeFactor^(iRound-1);
        bndBox(1) = bndBox(1) - 0.5*bndBox(3);
        bndBox(2) = bndBox(2) - 0.5*bndBox(4);
        bndBox = round(bndBox);
        adaptBndBox(iObj,:) = bndBox;
    
        %% load the pic
        pic = imcrop(core, bndBox);
    
        %% mount it
        data(:,:, : ,iObj) = im2single(imresize(pic, [100 100]));

    end

    %% run the CNN on it
    ValRes = vl_simplenn(BudNet,data);
    probBudYes = squeeze(ValRes(end).x(:,:,1,:));
    probBudNo=squeeze(ValRes(end).x(:,:,2,:));

    %% gallery (if desired)
    if vis

        nYes = sum(probBudYes > probBudNo  & probBudYes > treshValue);
        nYes = ceil(sqrt(nYes));
        nNo = size(adaptBndBox,1) - nYes;
        nNo = ceil(sqrt(nNo));
        nIterYes = 1;
        nIterNo = 1;
    
        figure(45), imagesc(core);
    
        for i =1:numel(ObjectData)
    
            pic = imcrop(core, round(adaptBndBox(i,:)));
            green = ones(size(pic(:,:,2)));
            green =  padarray(green, [2 2],'both');
            green = uint8(~green.*256);
            pic = padarray(pic, [2 2],'both');
        
            if probBudYes(i) > probBudNo(i) &&  probBudYes(i) > treshValue
            
                fig45 = figure(45);
                rectangle('Position', adaptBndBox(i,:), 'EdgeColor', 'g');
            
                pic(:,:,2) =pic(:,:,2) + green;
            
                fig42 = figure(42);
                subplot(nYes, nYes, nIterYes), 
                imagesc(pic)
                title(['Bud-prob = ', num2str(probBudYes(i))])
                nIterYes = nIterYes +1;
            
            else
            
                fig45 = figure(45);
                rectangle('Position', adaptBndBox(i,:), 'EdgeColor', 'r');
        
                pic(:,:,1) =pic(:,:,1) + green;
            
                fig43= figure(43);
                subplot(nNo, nNo, nIterNo), 
                imagesc(pic)
                title({['Bud-prob = ', num2str(probBudYes(i))],
                    ['Bud-prob no = ', num2str(probBudYes(i)) ]})
                nIterNo = nIterNo +1;
            end

        end
    
        if nIterYes > 1
            set(fig42,'Name',...
                ['All (n=',num2str(nIterYes-1),') correct buds in round #', num2str(iRound)],...
                'NumberTitle','off');
        end
    
    if nIterNo > 1
        set(fig43,'Name',...
            ['All (n=',num2str(nIterNo-1),') incorrect buds in round #', num2str(iRound)],...
            'NumberTitle','off');
    end
   
     set(fig45,'Name',...
            ['Results for positive (n=', num2str(nIterYes-1),...
            ') and negative (n=', num2str(nIterNo-1),') proposals in round #', num2str(iRound)'],...
            'NumberTitle','off');
    
    end
    
    %% round -output and function output-layer
    idx = probBudYes > probBudNo  & probBudYes > treshValue; % wieso hier nur ein &; verstehe wer will
    
    if iRound ==1
        ObjectDataOut = ObjectData(idx);
        ObjectData(idx) = [];
        
        if sum(idx) == numel(ObjectData)
            return
        end
        
    else
        tObjectDataOut = ObjectData(idx);       
        ObjectDataOut= cat(2,ObjectDataOut, tObjectDataOut);
        ObjectData(idx) = []; % remove it for the next round
    end
    
end

%% output layer



end
