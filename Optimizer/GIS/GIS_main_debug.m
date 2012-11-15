function CRFmodel = GIS_main_debug(config_file)
%GIS_main GIS main process (debug)
%   last mod:   $mar 10, 2011; 21:36$
%   DEBUG:

%% Initialization
% load configurations
eval(config_file);
CRFmodel.Optimizer = 'GIS';
CRFmodel.GIS = GIS;

%% Pre-steps
% % pre-process TrainData
% [CRFmodel.Data.Ny, CRFmodel.Data.Nx, CRFmodel.Data.Xtype, CRFmodel.Data.Ytype] = do_ProcData(config_file);
% % pre-process Templates
% [CRFmodel.AEtemplates, CRFmodel.TotalFeat, CRFmodel.FeatSeg, CRFmodel.Ulist, CRFmodel.Blist, CRFmodel.FFs] = do_ProcTemplate(config_file,CRFmodel);
% % save CRFmodel for safe!
% save(fullfile(RootPath,FolderData,'CRFmodel.mat'),'CRFmodel');
load(fullfile(RootPath,FolderData,'CRFmodel.mat'));
% % compute Pejxy, Pex
% [CRFmodel.Data.Pejxy,CRFmodel.Data.Pex] = do_ComputePe(config_file);
% compute slack feature S
% CRFmodel.GIS.S = do_ComputeConstS(config_file, CRFmodel);
CRFmodel.GIS.S = CRFmodel.TotalFeat;

%% Generate initial random parameter(vector) ParamVector
CRFmodel.ParamVector = rand(1,CRFmodel.TotalFeat);

%% Loop
DeltaUpdate = zeros(1,CRFmodel.TotalFeat);

IterTime = 0;
fprintf('STOP criterion: %.8f; GIS Optimizer start!\n',CRFmodel.GIS.Criterion);
fprintf('Step size(constant): %.10f.\n', 1/CRFmodel.GIS.S);
while 1
    % update M
    %     do_ComputeM(config_file,CRFmodel);
    %     for i=1:CRFmodel.TotalFeat
    %         % compute Ee, Em.
    %         [Ee, Em] = do_ComputeEeEm(config_file,CRFmodel, i);
    %         % update paramters
    %         DeltaUpdate(1,i) = (log(Ee/Em))/CRFmodel.GIS.S;
    %         CRFmodel.ParamVector(1,i) = CRFmodel.ParamVector(1,i) + DeltaUpdate(1,i);
    %     end
    
    for i=1:CRFmodel.TotalFeat
        % compute Ee, Em.
        [Ee, Em] = do_ComputeEeEm(config_file,CRFmodel, i);
        % update paramters
        DeltaUpdate(1,i) = (log(Ee/Em))/CRFmodel.GIS.S;
        CRFmodel.ParamVector(1,i) = CRFmodel.ParamVector(1,i) + DeltaUpdate(1,i);
    end
    
    IterTime = IterTime+1;
    fprintf('GIS %d-th iteration done!...\n',IterTime);
    
    % break!
    if IterTime <= GIS.MaxIter
        break;
    end
    if DeltaUpdate <= GIS.Criterion
        break;
    end
end

end