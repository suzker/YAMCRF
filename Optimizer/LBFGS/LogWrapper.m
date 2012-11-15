function [fval,fgrad] = LogWrapper(ParamV)
%LOGWRAPPER wrapper of the original loglikelihood function: 'GetLogLikelihood'
%   According to 'fminlbfgs',if the option 'GradObj' is on, the output must
%   contains both 'fval' and 'fgrad'. Computing 'fgrad' here will make the
%   whole optimization process fast.
%
%   Input: ParamV,  parameter vector
%   Output:fval,    function value
%   
%   Mod:    $12-Apr-2011 09:50:22$
%   Debug:  $$

%% init
% load config_file, where 'config_file' is global
global config_file;
eval(config_file);

% load model
load(fullfile(RootPath,FolderData,'CRFmodel.mat')); % load as CRFmodel

% load train data bundle
load(fullfile(RootPath,FolderData,'TrainDataBundle.mat')); % load as TrainDataBundle

% assign updated ParamV to CRFmodel
CRFmodel.ParamVector = ParamV;

% computeM
do_ComputeM(config_file,CRFmodel, 'TrainData',0);

% load computed matrixM
load(fullfile(RootPath,FolderData,'MatrixM','allM_TrainData.mat')); % load as 'allM'

% compute Z
z = ones(1,CRFmodel.Data.TrainTotal);
for i_TrainData = 1:CRFmodel.Data.TrainTotal
    ztemp = 1;
    Ntoken = length(TrainDataBundle(i_TrainData).Xseq);
    for i_token = 1 : Ntoken+1
        ztemp = allM(i_TrainData).matrixM{i_token}*ztemp;
    end
    z(1,i_TrainData)=ztemp(strcmp(CRFmodel.Data.Ytype,'CRF_SPECIAL_START'),strcmp(CRFmodel.Data.Ytype,'CRF_SPECIAL_STOP'));
end

% compute Em

%% core
% return Lhood, which is also the fval
fval = - GetLogLikelihood(config_file, TrainDataBundle ,CRFmodel, z);
fgrad = GradLogLikelihood(config_file, TrainDataBundle ,CRFmodel, z);

end

