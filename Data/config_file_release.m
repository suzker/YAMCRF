%% About
%   Configuration File for Conditional Random Fileds
%% Location
%   set root
RootPath = fullfile('~/WD2T/','YAMCRF');   % Unix
% RootPath = fullfile('f:\','YAMCRF');   % Win32
path(RootPath,path);

%% Main Folders
%   datas
FolderData = 'Data';
%path(fullfile(RootPath,FolderData),path);

%   results
FolderResult = 'Result';

%   common functions
FolderCommon = 'Common';
% path(fullfile(RootPath,FolderCommon),path);

%   Optimizers
FolderOptimizer = 'Optimizer';
% path(fullfile(RootPath,FolderOptimizer));

%   GIS
FolderGIS = 'GIS';
% path(fullfile(RootPath,FolderOptimizer,FolderGIS),path);

%   IIS
FolderIIS = 'IIS';
% path(fullfile(RootPath,FolderOptimizer,FolderIIS),path);

%   LBFGS
FolderLBFGS = 'LBFGS';
% path(fullfile(RootPath,FolderOptimizer,FolderLBFGS),path);

%% Model Configurations
Model.SelOptimizer = 'LBFGS';
Model.SelDecoder = 'Viterbi';

%% Configuration - GIS

if strcmp(Model.SelOptimizer,'GIS')
    % stop criterion
    GIS.Criterion = 0.01;
    % Max iteration
    GIS.MaxIter = 100;
end

%% Configuration - LBFGS

if strcmp(Model.SelOptimizer,'LBFGS')
    % stop criterion
    LBFGS.Criterion = 0.01;
    % Max iteration
    LBFGS.MaxIter = 100;
    % select 'm' pair of {s_k,y_k} to reconstruct Hessian.

    % LBFGS.options
    LBFGS.options = struct('GradObj','on', ...
        'Display','iter',...
        'HessUpdate','lbfgs',...
    'MaxIter',100,...
    'StoreN',20);
end