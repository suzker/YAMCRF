function CRFmodel = GIS_main(config_file)
%GIS_main GIS main process
%   last mod:   $01-APR-2011 13:55:37$
%   DEBUG:      $27-Mar-2011 13:55:37$

%% Initialization
% load configurations
eval(config_file);

% load model
load(fullfile(RootPath,FolderData,'CRFmodel.mat')); % load as CRFmodel

CRFmodel.Optimizer = 'GIS';
CRFmodel.GIS = GIS;
diary off;

% compute Pejxy, Pex
[CRFmodel.Data.Pejxy,CRFmodel.Data.Pex] = do_ComputePe(config_file);
% compute slack feature S
CRFmodel.GIS.S = do_ComputeConstS(config_file, CRFmodel);

%% Generate initial random parameter(vector) ParamVector
CRFmodel.ParamVector = rand(1,CRFmodel.TotalFeat);
% save CRFmodel for safety!
save(fullfile(RootPath,FolderData,'CRFmodel.mat'),'CRFmodel');
%% Loop
clc;
CRFmodel.Time = datestr(now);
CRFmodel.Time(CRFmodel.Time == ':')='';
CRFmodel.Time(CRFmodel.Time == ' ')='';

RecDirName = sprintf('Result-%s',CRFmodel.Time);
mkdir(fullfile(RootPath,FolderResult,RecDirName));

% record command window output
diary(fullfile(RootPath,FolderResult,RecDirName,'TrainOuputs'));

load(fullfile(RootPath,FolderData,'TrainDataBundle.mat'));
IterTime = 0;
fprintf('STOP criterion: %.8f; GIS Optimizer start!\n',CRFmodel.GIS.Criterion);
fprintf('Max Iter.: %d\n',GIS.MaxIter);
fprintf('Step size(constant): %.10f.\n', 1/CRFmodel.GIS.S);
disp(CRFmodel.Time);

% load all train data as a bundle
load(fullfile(RootPath,FolderData,'TrainDataBundle.mat')); %'TrainDataBundle'

% compute expectation of feat' func' w.r.t empirical distribution
EeV = do_ComputeEe(CRFmodel, TrainDataBundle);

% compute M for the first time
do_ComputeM(config_file,CRFmodel, 'TrainData',0);

% load matrixM
load(fullfile(RootPath,FolderData,'MatrixM','allM_TrainData.mat')); % load as 'allM'

% compute Z for the first time
z = ones(1,CRFmodel.Data.TrainTotal);
for i_TrainData = 1:CRFmodel.Data.TrainTotal
    ztemp = 1;
    Ntoken = length(TrainDataBundle(i_TrainData).Xseq);
    for i_token = 1 : Ntoken+1
        ztemp = allM(i_TrainData).matrixM{i_token}*ztemp;
    end
    z(1,i_TrainData)=ztemp(strcmp(CRFmodel.Data.Ytype,'CRF_SPECIAL_START'),strcmp(CRFmodel.Data.Ytype,'CRF_SPECIAL_STOP'));
end

% result record
ResultRec = zeros(GIS.MaxIter,3);

% start!
disp('/*************************START************************************/');
while 1
    tic
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
    
    % current loglikelihood
    L_current = GetLogLikelihood(config_file,TrainDataBundle,CRFmodel,z);
    EmV = do_ComputeEm(CRFmodel, TrainDataBundle ,HugeFB, HugeFMB);
    
    DeltaUpdateV = (log(EeV./EmV))./CRFmodel.GIS.S;
    CRFmodel.ParamVector = CRFmodel.ParamVector + DeltaUpdateV;
    
    % make -Inf parameter entries 0
    CRFmodel.ParamVector(isinf(CRFmodel.ParamVector)) = 0;
    
    % compute new M-matrixies
    do_ComputeM(config_file,CRFmodel, 'TrainData',1);
    
    % load new M-matrixies
    load(fullfile(RootPath,FolderData,'MatrixM','allM_TrainData.mat')); % load as 'allM'
    
    % compute new Z
    for i_TrainData = 1:CRFmodel.Data.TrainTotal
        ztemp = 1;
        Ntoken = length(TrainDataBundle(i_TrainData).Xseq);
        for i_token = 1 : Ntoken+1
            ztemp = allM(i_TrainData).matrixM{i_token}*ztemp;
        end
        z(1,i_TrainData)=ztemp(strcmp(CRFmodel.Data.Ytype,'CRF_SPECIAL_START'),strcmp(CRFmodel.Data.Ytype,'CRF_SPECIAL_STOP'));
    end
    
    % updated loglikelihood
    L_updated = GetLogLikelihood(config_file,TrainDataBundle,CRFmodel,z);
    
    toc
    
    % finally @_@
    fprintf('Old loglikelihood: %.8f vs. New loglikelihood: %.8f.\n',L_current, L_updated);
    diff = L_updated - L_current;
    IterTime = IterTime+1;
    fprintf('log'' diff.: %.10f.\n', diff);
    fprintf('GIS %d-th iteration... done!\n',IterTime);
    ResultRec(IterTime,:)=[L_current, L_updated, diff];
    disp('----------------------------------------------------------------');
        
    % break!
    if IterTime == GIS.MaxIter
        break;
    end
    if diff <= GIS.Criterion
        break;
    end
end
disp('/*************************STOP*************************************/');

diary off;

% visualization
ResultRec(ResultRec==0)=[];
figure;
title('Loglikelihood Diff.');
subplot(2,1,1)
hold on;
plot(ResultRec(:,1),'rv'); %old loglikelihoods
plot(ResultRec(:,2),'g^'); %new loglikelihoods
legend('old loglikelihood','new loglikelihood');
subplot(2,1,2)
hold on;
plot(ResultRec(:,3),'--bs','LineWidth',2, 'MarkerEdgeColor','k', 'MarkerFaceColor','g',  'MarkerSize',3);
legend('likelihood diff.');
hold off;

% save CRFmodel for safety!
save(fullfile(RootPath,FolderData,'CRFmodel.mat'),'CRFmodel');
copyfile(fullfile(RootPath,FolderData,'CRFmodel.mat'),fullfile(RootPath,FolderResult,RecDirName,sprintf('model-%s.mat',CRFmodel.Time)));
end