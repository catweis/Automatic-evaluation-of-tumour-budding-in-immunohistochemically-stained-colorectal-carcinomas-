
function net = func_initializeBudCNN(imdb)

f=1/100 ;
clear net
net.layers = {} ;
dim = {};

%% layer #1 ---------------------------------------------------------------

% define parameter and hyperparameter
if exist('imdb')
    inputDim = imdb.inputSize;
else
    inputDim = [100 100 3];
end
Dim(1).input = inputDim;

convFilter = randn(21, 21, 3, 50, 'single');
padding = 0;
stride = 1;
% create layer 
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*convFilter , zeros(1, 50, 'single')}}, ...
                           'stride', stride, ...
                           'pad', padding) ;
% calculate the dimensions of the results  
[dimX dimY] = calcoutputdim(inputDim, convFilter, padding, stride);
outputDim = [dimX dimY 1 size(convFilter,4)];
Dim(end).output = outputDim;

%% layer #2 // relu-layer ------------------------------------------------- 
% create layer
inputDim = outputDim;
Dim(end+1).input = inputDim;
net.layers{end+1} = struct('type', 'relu') ;
Dim(end).output = outputDim;

%% layer #3 ----------------------------------------------------------------
% define parameter / hyperparameter
inputDim = outputDim;
Dim(end+1).input = inputDim;
% create layer
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [4 4], ...
                           'stride', 4, ...
                           'pad', 0) ;
% per definition divided by 2
dimX = dimX /4; dimY = dimY /4; 
outputDim = [dimX dimY inputDim(3) inputDim(4)];
Dim(end).output = outputDim;


%% layer #4 // conv-layer -------------------------------------------------
% define parameter / hyperparameter
inputDim = outputDim;
Dim(end+1).input = inputDim;
convFilter = randn(3, 3, 50, 50, 'single');
padding = 0;
stride = 1;
% create layer 
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*convFilter , zeros(1, 50, 'single')}}, ...
                           'stride', stride, ...
                           'pad', padding) ;
% calculate the dimensions of the results  
[dimX dimY] = calcoutputdim(inputDim, convFilter, padding, stride);
outputDim = [dimX dimY 1 size(convFilter,4)];
Dim(end).output = outputDim;

%% layer #5 // relu-layer ------------------------------------------------- 
% create layer
inputDim = outputDim;
Dim(end+1).input = inputDim;
net.layers{end+1} = struct('type', 'relu') ;
Dim(end).output = outputDim;

%% layer #6 ----------------------------------------------------------------
% define parameter / hyperparameter
inputDim = outputDim;
Dim(end+1).input = inputDim;
% create layer
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [2 2], ...
                           'stride', 2, ...
                           'pad', 0) ;
% per definition divided by 2
dimX = dimX /2; dimY = dimY /2; 
outputDim = [dimX dimY inputDim(3) inputDim(4)];
Dim(end).output = outputDim;


%% layer #7 // last-conv-layer (fully connected) -------------------------
% define parameter and hyperparameter
inputDim = outputDim;
Dim(end+1).input = inputDim;
convFilter = randn(outputDim(1),outputDim(2),outputDim(4),2, 'single');
padding = 0;
stride = 1;
% create layer
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*convFilter, zeros(1,2,'single')}}, ...
                           'stride', stride, ...
                           'pad', padding) ;
% calculate the dimensions of the results
[dimX dimY] = calcoutputdim(inputDim, convFilter, padding, stride);
outputDim = [dimX dimY 1 size(convFilter,4)];     
Dim(end).output = outputDim;

%% decide if the network - wie soll man es sagen - converges?
if outputDim == [1 1 1 2]
    disp('Network is okay')
else
    disp('Network is prone to malfunction')
end

%% layer #12 // last layer -> das bleibt dann auch stehen
inputDim = outputDim;
Dim(end+1).input = inputDim;
net.layers{end+1} = struct('type', 'sigmoid') ;
Dim(end).output = outputDim;

%% layer #13 // last layer for learning -> softmaxloss
%create layer
inputDim = outputDim;
Dim(end+1).input = inputDim;
net.layers{end+1} = struct('type', 'softmaxloss') ;
Dim(end).output = outputDim;

%% tidy up the net (warum auch immer)
net = vl_simplenn_tidy(net) ;
net.dim = Dim;

end