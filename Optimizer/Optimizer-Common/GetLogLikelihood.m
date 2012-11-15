function Lhood = GetLogLikelihood(config_file, TrainDataBundle ,CRFmodel, z)
%GETLOGLIKELIHOOD Return the loglikelihood of current model
%   Inputs: CRFmodel, config_file, z
%   Output: Lhood, loglikelihood
%
%   Mod:    $23-Mar-2011 21:43:28$
%   Debug:  $25-Mar-2011 21:40:45$
%% init
eval(config_file);
Lhood = 0;
load(fullfile(RootPath,FolderData,'MatrixM','allM_TrainData.mat')); % load as 'allM'

%% main
for i_TrainData = 1:CRFmodel.Data.TrainTotal
    temp = 1;
    for i_token = 2 : length(TrainDataBundle(i_TrainData).i_Yseq)
        temp = temp * allM(i_TrainData).matrixM{i_token-1}(TrainDataBundle(i_TrainData).i_Yseq(i_token-1),TrainDataBundle(i_TrainData).i_Yseq(i_token));
    end
    Lhood = Lhood + CRFmodel.Data.Pejxy(i_TrainData)*log(temp/z(i_TrainData));
end

end