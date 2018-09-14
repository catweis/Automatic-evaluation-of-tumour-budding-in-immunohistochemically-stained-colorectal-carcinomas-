function [DataCore, Res, varargout] = main_coreanalysis(CurrentCore, Prmetr)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% input layer
Res = cell(0,1);
DataCore1 = CoreData;

%% perform the analysis
% analysis
[Res{end+1}, StatData, coreMod] = ....
        func_spatialstats(CurrentCore, 2, Prmetr,  Prmetr.vis);

% mount it 
DataCore = DataCore1;
DataCore.ObjectData= Res{end};

if Prmetr.vis
   fig42 = figure(); vis(DataCore)
   set(fig42,'Name',...
        'Results of bud-proposal generation',...
        'NumberTitle','off');
end
    
%% reduce the results and check the results
% by size
if Prmetr.adaptSize
    
    tic
    [Res{end+1}] = func_removebig(Res{end}, DataCore,Prmetr.budSize, Prmetr.vis);
    
    DataCore = DataCore1;
    DataCore.ObjectData= Res{end}; % -> mount the output of that loop
    
    if Prmetr.vis
        fig42 = figure(42); vis(DataCore)
        set(fig42,'Name',...
        'Results after area-based reduction',...
        'NumberTitle','off');
    end
    
    t = toc;
    disp(['Area-based clustering finished in ', num2str(t), 's.'])
    
end

%% reduce the results and check the results
% by CNN
if Prmetr.adaptImage

    [Res{end+1}] = ...
             func_checkresults(Res{end}, CurrentCore, [], ...
             Prmetr.vis, Prmetr.bndBoxSizeFactor, Prmetr.CNNRounds);
   
    t= toc;
    disp(['CNN-based clustering finished in ', num2str(t), 's.'])
   
end

%% output layer
Results = Res{end};
DataCore = DataCore1;
DataCore.ObjectData = Results;
DataCore.image = CurrentCore;

end

