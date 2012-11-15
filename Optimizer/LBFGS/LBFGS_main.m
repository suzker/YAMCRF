function CRFmodel = LBFGS_main(config_file)
%GIS_main GIS main process
%   last mod:   $11-APR-2011 20:51:30$
%   DEBUG:      $$

%% Initialization
diary off;
% load configurations
eval(config_file);

% load model
load(fullfile(RootPath,FolderData,'CRFmodel.mat')); % load as CRFmodel

CRFmodel.Time = datestr(now);
CRFmodel.Time(CRFmodel.Time == ':')='';
CRFmodel.Time(CRFmodel.Time == ' ')='';
CRFmodel.Optimizer = 'LBFGS';
CRFmodel.LBFGS = LBFGS;

% init parameter
CRFmodel.ParamVector = rand(1,CRFmodel.TotalFeat);

% compute Pejxy, Pex
[CRFmodel.Data.Pejxy,CRFmodel.Data.Pex] = do_ComputePe(config_file);

% load train data bundle
load(fullfile(RootPath,FolderData,'TrainDataBundle.mat')); % load as TrainDataBundle

% compute EeV for gradient
CRFmodel.LBFGS.EeV = do_ComputeEe(CRFmodel, TrainDataBundle);

% save model!
save(fullfile(RootPath,FolderData,'CRFmodel.mat'),'CRFmodel');

%% MAIN
clc
% diary on
RecDirName = sprintf('Result-%s',CRFmodel.Time);
mkdir(fullfile(RootPath,FolderResult,RecDirName));
diary(fullfile(RootPath,FolderResult,RecDirName,'TrainOuputs'));

% lbfgs core
[CRFmodel.ParamVector,fval,exitflag,output,grad]=fminlbfgs(@LogWrapper,CRFmodel.ParamVector,CRFmodel.LBFGS.options);
diary off;
save(fullfile(RootPath,FolderData,'CRFmodel.mat'),'CRFmodel');
end

