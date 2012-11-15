function GradLhood = GradLogLikelihood(config_file, TrainDataBundle, CRFmodel, z)
%GRADLOGLIKELIHOOD Return Gradient of loglikelihood
%   Detailed explanation goes here

%% init
eval(config_file);

%% main
% create a huge matrix or vector to boost the computation of Ee/Em
% edge feature版本暂缺 20110315 2133
HugeFMB = zeros(CRFmodel.Data.Ny, CRFmodel.Data.Ny * CRFmodel.Data.TokenTotal);
HugeFB = zeros(CRFmodel.Data.Ny * CRFmodel.Data.TokenTotal,1);

load(fullfile(RootPath,FolderData,'MatrixM','allM_TrainData.mat')); % load as 'allM'

postag = 0;
posfront = 0;
counttemp = 0;
for i_TrainData = 1:CRFmodel.Data.TrainTotal
    [FF,BF] = ComputeFB(allM(i_TrainData).matrixM, CRFmodel, length(TrainDataBundle(i_TrainData).Xseq));
    Ntoken = length(TrainDataBundle(i_TrainData).Xseq);
    for i_token = 1 : Ntoken
        HugeFB(postag+1:postag+CRFmodel.Data.Ny) = FF{i_token+1} .* BF{i_token};
        postag = postag + CRFmodel.Data.Ny;
        counttemp = counttemp+1;
    end
    HugeFB(posfront+1:postag)=HugeFB(posfront+1:postag)./z(1,i_TrainData).*CRFmodel.Data.Pex(i_TrainData);
    posfront = postag;
end

EmV = do_ComputeEm(CRFmodel, TrainDataBundle ,HugeFB, HugeFMB);
GradLhood = EmV - CRFmodel.LBFGS.EeV;
end

