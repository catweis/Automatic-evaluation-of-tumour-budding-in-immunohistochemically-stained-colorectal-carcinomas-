
function [RGB] = func_deconcolour(picture, OnOff, varargin)

%% input layer

if ~exist('OnOff'), OnOff = 'Off'; end

%% set the colour values
C1 = [0.6443186, 0.7166757, 0.26688856]'; % blau
C2 = [0.09283128, 0.9545457, 0.28324]'; % für braun
C3 = [0.63595444, 0.001, 0.7717266]'; % grün

%C1 = [0.65; 0.70; 0.29];
%C2 = [0.07; 0.99; 0.11];
%C3 = [0.27; 0.57; 0.78];

%% Convert RGB intensity to optical density (absorbance)
sampleRGB_OD = -log((double(picture)+1)./256);

%%Construct color deconvolution matrix
% Take the average around region of interest
H2 = ones(10,10) ./ 100;
[height width channel] = size(picture);

M = [C1/norm(C1) C2/norm(C2) C3/norm(C3)];
D = inv(M);
%% Apply Color Deconvolution /
SampleOD = zeros(height, width, channel);
RGB =mat2cell(sampleRGB_OD, [ones(height,1)], width,3);

% perform the calculation / by matrix multiplication to reduce calculation
% time
for i=1:height
    RGB{i} = shiftdim(squeeze(RGB{i}),1);
    RGB{i} = D*RGB{i};
end

clear RGBColour
% recompose the resuluts
for n=1:3
    for i=1:height
        RGBColour{i,1} = RGB{i}(n, 1:width);
    end
  
    SampleOD(:,:,n) = cell2mat(RGBColour);
    [SampleOD(:,:,n)] = mapvalues(SampleOD(:,:,n));
end

%% visualization part

switch OnOff
    
    case 'On'
   
        figure(),
        subplot(2,3,1), imagesc(picture)
        for dim =1:3
            subplot(2,3,dim+3), imagesc(SampleOD(:,:,dim)), colormap 'parula', colorbar
        end
        
end

%% map the contrast




%% output-layer
clear RGB
RGB.blue = SampleOD(:,:,1);
RGB.red = SampleOD(:,:,2);
RGB.green = SampleOD(:,:,3);

end


function [dataOut] = mapvalues(dataIn)

%% find the min and max value
minValue = min(dataIn(:));
maxValue = max(dataIn(:));

%% Gleichungssystem
a = -100 / (minValue-maxValue);
b = -a * minValue;

%% Anwendung des Gleichungssytems
dataOut =b +  dataIn .*a ;

end
