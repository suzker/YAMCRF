clear;
clc;
%% Infos
disp('1D Chain-CRF demo');
%% Init
global config_file;
config_file = 'config_file_release';
eval(config_file);
%% Data
% mkdir if necessary
if ~exist(fullfile(RootPath,FolderData,'TestData'),'dir')
    mkdir(fullfile(RootPath,FolderData,'TestData'));
    addpath(fullfile(RootPath,FolderData,'TestData'));
end

if ~exist(fullfile(RootPath,FolderData,'TrainData'),'dir')
    mkdir(fullfile(RootPath,FolderData,'TrainData'));
    addpath(fullfile(RootPath,FolderData,'TrainData'));
end

if ~exist(fullfile(RootPath,FolderData,'MatrixM'),'dir')
    mkdir(fullfile(RootPath,FolderData,'MatrixM'));
    addpath(fullfile(RootPath,FolderData,'MatrixM'));
end

% Transform CRF++ data to our standard data format (comment them if you've already did the transform)
% CRFppTransform(config_file,' ','train.data')
% CRFppTransform(config_file,' ','test.data')

%% train
CRFmodel = struct();

% pre-process TrainData
[CRFmodel.Data.Ny, CRFmodel.Data.Nx, CRFmodel.Data.Xtype, ...
    CRFmodel.Data.Ytype, CRFmodel.Data.TokenTotal, CRFmodel.Data.TrainTotal] ...
    = do_ProcData(config_file);
% pre-process Templates
[CRFmodel.AEtemplates, CRFmodel.TotalFeat, CRFmodel.FeatSeg, CRFmodel.Ulist,...
    CRFmodel.Blist, CRFmodel.FFs, CRFmodel.i_Xexp_train, CRFmodel.i_Xexp_test] ...
    = do_ProcTemplate(config_file,CRFmodel);
% save CRFmodel for safety!
save(fullfile(RootPath,FolderData,'CRFmodel.mat'),'CRFmodel');

% modify 'config_file' to select your optimizer
switch upper(Model.SelOptimizer)
    case 'GIS'
        CRFmodel = GIS_main(config_file);
    case 'IIS'
        CRFmodel = IIS_main(config_file);
    case 'LBFGS'
        CRFmodel = LBFGS_main(config_file);
    otherwise
        CRFmodel = GIS_main(config_file);
end

%% test
% modify 'config_file' to select your decoder
switch upper(Model.SelDecoder)
    case 'VITERBI'
        TestResult = Viterbi_main(config_file);
    case 'BP'
        TestResult = BP_main(config_file);
    otherwise
        TestResult = Viterbi_main(config_file);
end

%% evaluation
%% end