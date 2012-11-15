function [Pejxy,Pex] = do_ComputePe(config_file)
%DO_COMPUTEPE Compute the empirical joint distribution ~p(x,y) and the
%empirical distribution of x: ~p(x)
%   input:  config_file
%   output: Pejxy, Pex
%           'Pejxy', 'Pex' will also be saved.
%
%   Latest mod: $feb 26, 2011; 16:07$
%   Debug:  $mar 12, 2011; 18:09$

%% Initialization
eval (config_file)
fprintf('Computing empirical joint distribution ~p(x,y) and ~p(x)...');

%% Main
TrainFiles = dir(fullfile(RootPath,FolderData,'TrainData','*.mat'));
SizeFeatSpace = length(TrainFiles);
% empirical joint distribution: ~p(x,y)
Pejxy = zeros(1,length(TrainFiles));
% empirical distribution of x: ~p(x)
Pex = zeros(1,length(TrainFiles));

for i = 1:length(TrainFiles)
    % load the ith pair of train data:
    %   load as 'TrainDataA' containing 'Yseq', 'Xseq'
    TrainDataA = load(fullfile(FolderData,'TrainData',TrainFiles(i).name));
    TimeXYEqual = 0;
    TimeXEqual = 0;
    
    for j= 1:length(TrainFiles)
        % load the jth pair of train data:
        %   load as 'TrainDataA' containing 'Yseq', 'Xseq'
        TrainDataB = load(fullfile(FolderData,'TrainData',TrainFiles(j).name));
        if length(TrainDataA.TrainData.Xseq) == length(TrainDataB.TrainData.Xseq)
            if strcmp(TrainDataA.TrainData.Xseq,TrainDataB.TrainData.Xseq)
                TimeXEqual = TimeXEqual + 1;
                if strcmp(TrainDataA.TrainData.Yseq,TrainDataB.TrainData.Yseq)
                    TimeXYEqual = TimeXYEqual + 1;
                end
            end
        end
    end
    % get Pejxy
    Pejxy(1,i) = TimeXYEqual / SizeFeatSpace;
    Pex(1,i) = TimeXEqual / SizeFeatSpace;
end
% save (fullfile(RootPath,FolderData,'Pejxy'),'Pejxy');
% save (fullfile(RootPath,FolderData,'Pex'),'Pex');

disp(' done!');
end

