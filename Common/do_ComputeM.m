function do_ComputeM(config_file, CRFmodel, target, dispflag)
%DO_COMPUTEM for each position in each train/test data, compute matrix M
%to creat a struct call 'AllM'. (Bootsted!)
%   Inputs: config_file, CRFmodel
%           target, 'TrainData' 'TestData' or 'ConstS'.
%           disp, to display status or not.
%   Output: None
%
%   feature: much faster and fewer memories are needed.
%
%   Last mod:   $27-Mar-2011 17:51:14$
%   debug:      $27-Mar-2011 18:01:06$

%% Initialization
eval(config_file);

if dispflag
fprintf('Computing matrix M for current data...');
end
allM = struct();

switch lower(target)
    case 'traindata'
        % list all train data pair
        ListData = dir(fullfile(RootPath,FolderData,'TrainData','*.mat'));
        i_Xexp = CRFmodel.i_Xexp_train;
        savename = 'TrainData';
    case 'testdata'
        % list all train data pair
        ListData = dir(fullfile(RootPath,FolderData,'TestData','*.mat'));
        i_Xexp = CRFmodel.i_Xexp_test;
        savename = 'TestData';
    case 'consts'
        CRFmodel.ParamVector = ones(1,CRFmodel.TotalFeat);
        % list all train data pair
        ListData = dir(fullfile(RootPath,FolderData,'TrainData','*.mat'));
        i_Xexp = CRFmodel.i_Xexp_train;
        target = 'TrainData';
        savename = 'ConstS';
    otherwise
        error('invalid input!');
end

%% main loop
for i_data = 1 : length(ListData)
    % load a data, whatever it is...
    load(fullfile(RootPath,FolderData,target,ListData(i_data).name)); %load as 'data'
    if exist('TrainData','var')
        data = TrainData;
    else
        data = TestData;
    end
    
    % hugeM to store matries for current data
    hugeM = zeros(CRFmodel.Data.Ny,(length(data.Xseq)+1)*CRFmodel.Data.Ny);
    temp_pos = 0;
    
    for i_temp = 1 : length(CRFmodel.AEtemplates)
        if strcmp(CRFmodel.AEtemplates(i_temp).featType,'U')
            % for node feature(unigram)
            NyFront = 1;
        else
            % for edge feature(bigram)
            NyFront = CRFmodel.Data.Ny;
        end
        
        PartiXexp = i_Xexp{i_temp}(1:length(data.Xseq)+1);
        % shrink i_Xexp
        i_Xexp{i_temp} = i_Xexp{i_temp}(length(data.Xseq)+2:end);
        
        Trigger = repmat(PartiXexp,NyFront*CRFmodel.Data.Ny*(length(CRFmodel.AEtemplates(i_temp).uExpFeat)),1);
        Trigger = reshape(Trigger,1,NyFront*CRFmodel.Data.Ny*(length(CRFmodel.AEtemplates(i_temp).uExpFeat))*length(PartiXexp));
        PartFFs = repmat(CRFmodel.FFs(temp_pos+1:CRFmodel.FeatSeg(i_temp),3),length(PartiXexp),1);
        PartPVs = repmat(CRFmodel.ParamVector(temp_pos+1:CRFmodel.FeatSeg(i_temp)),1,length(PartiXexp));
        
        Bullets = PartPVs(Trigger == PartFFs');
        
        % find where the X expanded feature is not included in AEtemplate.uExpFeat
        if length(Bullets) < size(hugeM,2)
            missingPos = find(PartiXexp==0);
            for i_miss = 1 : length(missingPos)
                Bullets = ...
                    [Bullets(1:(missingPos(i_miss)-1)*NyFront*CRFmodel.Data.Ny),...
                    zeros(1,NyFront*CRFmodel.Data.Ny),...
                    Bullets(((missingPos(i_miss)-1)*NyFront*CRFmodel.Data.Ny)+1:end)];
            end
        end
        % NOTE: according to this 'missingPos', zeros will be filled
        % automatically.
        
        if strcmp(CRFmodel.AEtemplates(i_temp).featType,'U')
            % for node feature(unigram)
            Params = repmat(Bullets,CRFmodel.Data.Ny,1);
        else
            % for edge feature(bigram)
            Params = reshape(Bullets,CRFmodel.Data.Ny,CRFmodel.Data.Ny)';
        end
        
        hugeM = hugeM + Params;
        
        % release memory
        clear Trigger; clear PartFFs; clear PartPvs; clear Params;
        temp_pos = CRFmodel.FeatSeg(i_temp);
    end
    
    hugeM = exp(hugeM);
    
    Ntoken = length(data.Xseq)+1;
    for i_token = 1 : Ntoken
        allM(i_data).matrixM{i_token} = hugeM(:,1:CRFmodel.Data.Ny);
        % shrink i_Xexp and prevent it from exceeding its size
        hugeM = hugeM(:,CRFmodel.Data.Ny+1:end);
    end
end

%% save
save(fullfile(RootPath,FolderData,'MatrixM',sprintf('allM_%s.mat',savename)),'allM');
if dispflag
disp('done!');
end
end