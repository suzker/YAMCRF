function GlobalMax = do_ComputeConstS(config_file, CRFmodel)
%DO_COMPUTECONSTS Compute S=max T(x,y) over all training data
%   input:  config_file
%   output: GlobalMax
%
%   mod:    $23-Mar-2011 21:15:02$
%   debug:  $25-Mar-2011 21:40:45$

%% initialization
eval(config_file);
GlobalMax = 0;
%% main
% compute special M for this task
do_ComputeM(config_file,CRFmodel, 'ConstS',0);

% list all train data pair
ListTrainData = dir(fullfile(RootPath,FolderData,'TrainData','*.mat'));
load(fullfile(RootPath,FolderData,'MatrixM','allM_ConstS.mat')); % load as allM
% for each traindata
for i_TrainData = 1 : size(ListTrainData,2)
    % load a train data
    load(fullfile(RootPath,FolderData,'TrainData',ListTrainData(i_TrainData).name)); %load as 'TrainData'

    lenSeq = length(TrainData.Xseq);
    
    % computeFB.
    [FF, ~] = ComputeFB(allM(i_TrainData).matrixM, CRFmodel, lenSeq);
    
    tempYResult = zeros(1,lenSeq);
    % Find maximum local labels
    for i_token = 1 : lenSeq
        [~,index_y_max] = max(FF{i_token+1});
        tempYResult(i_token) = index_y_max;
    end
    tempYResult = [find(strcmp(CRFmodel.Data.Ytype,'CRF_SPECIAL_START')),tempYResult,find(strcmp(CRFmodel.Data.Ytype,'CRF_SPECIAL_STOP'))];
    
    % compute active value for current xseq
    tempActFeat = 0;
    CRFmodel.ParamVector = ones(1,CRFmodel.TotalFeat);
    for i_token = 1 : length(TrainData.Xseq)+1
        i_y_front =tempYResult(i_token);
        i_y_rare = tempYResult(i_token+1);
        tempActFeat = tempActFeat + ...
            GetPotentialBoost(CRFmodel, i_token, TrainData, i_y_front, i_y_rare);
    end
    GlobalMax = max(GlobalMax,tempActFeat);
end
end