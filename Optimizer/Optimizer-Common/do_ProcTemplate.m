function [AEtemplates, TotalFeat, FeatSeg, Ulist, Blist, FFs, i_Xexp_train, i_Xexp_test]=do_ProcTemplate(config_file, CRFmodel)
%DO_PROCTEMPLATE Read Template File
%   Input: config_file, CRFmodel
%   Output: AEtemplates - Another expression of templates
%           TotalFeat   - number of generated features
%           FeatSeg     - feature segmentation
%           Ulist       - index of Unigram features
%           Blist       - index of Bigram featrues
%           FFs         - feature functions: cell
%           i_Xexp_train- index of X expanded feature for train data
%           i_Xexp_test - index of X expanded feature for test data
%
%   mod:	$24-Mar-2011 10:43:58$
%   debug:	$25-Mar-2011 21:40:45$

%% Initialization
eval(config_file);

%% Main
% another expression of templates
AEtemplates = struct([]);
% i_Xexp
AllXexp = struct();
i_Xexp = cell(1:length(AEtemplates));

% read templates
fid = fopen(fullfile(RootPath,FolderData,'RawData','template'),'r');
if fid ~= -1
    disp ('Template file successfully loaded.');
    AEtemplates = TemplateReader(fid);
    fclose(fid);
else
    disp ('Error while trying to read template file.');
    disp ('Program will halt, please check for errors.');
    return;
end

% evaluate all train data
%   list all train data pair
ListTrainData = dir(fullfile(RootPath,FolderData,'TrainData','*.mat'));
ListTestData = dir(fullfile(RootPath,FolderData,'TestData','*.mat'));

% crate a cell to store unique expanded features
for i_featTemp = 1 : length(AEtemplates)
    AEtemplates(i_featTemp).uExpFeat = cell(0,0);
end

%% train data
for i_TrainData = 1 : size(ListTrainData,1)
    % load a train data
    load(fullfile(RootPath,FolderData,'TrainData',ListTrainData(i_TrainData).name)); %load as 'TrainData'
    
    fprintf('Evaluating the %d-th TrainData... \n',i_TrainData);
    % loops
    %  for each feature teamplate
    for i_featTemp = 1 : length(AEtemplates)
        for i_token = 1 : length(TrainData.Xseq)+1
            % read expanded features
            tempExpFeat = '';
            for i_Exp = 1 : length(AEtemplates(i_featTemp).featExp)
                expXY = AEtemplates(i_featTemp).featExp{i_Exp};
                if expXY(1)+i_token < 1
                    tempExpFeat = [tempExpFeat, '/' ,'TokenOutOfUpperRange'];
                elseif expXY(1)+i_token > length(TrainData.Xseq)
                    tempExpFeat = [tempExpFeat, '/' ,'TokenOutOfLowerRange'];
                else
                    if expXY(2) == 0
                        tempExpFeat = [tempExpFeat,'/',TrainData.Wordseq{expXY(1)+i_token}];
                    elseif expXY(2) == 1
                        tempExpFeat = [tempExpFeat,'/',TrainData.Xseq{expXY(1)+i_token}];
                    end
                end
            end
            % skip the extra '/' character in front of tempExpFeat
            tempExpFeat = tempExpFeat(2:end);
            AllXexp(i_TrainData).template(i_featTemp).Xexp(i_token).ExpFeat = tempExpFeat;
            % add temperaty expanded feature and make them unique ;-)
            if i_token ~= length(TrainData.Xseq)+1
                AEtemplates(i_featTemp).uExpFeat = unique([AEtemplates(i_featTemp).uExpFeat,tempExpFeat]);
            end
        end
    end
end


for i_featTemp = 1 : length(AEtemplates)
    temp_i_xexp = zeros(1,CRFmodel.Data.TokenTotal);
    posa=0;
    for i_TrainData = 1 : size(ListTrainData,1)
        % load a train data
        load(fullfile(RootPath,FolderData,'TrainData',ListTrainData(i_TrainData).name)); %load as 'TrainData'
        for i_token = 1 : length(TrainData.Xseq)+1
            posa = posa + 1;
            if isempty(find(strcmp(AEtemplates(i_featTemp).uExpFeat,AllXexp(i_TrainData).template(i_featTemp).Xexp(i_token).ExpFeat), 1))
                temp_i_xexp(1,posa) = 0;
            else
                temp_i_xexp(1,posa) = find(strcmp(AEtemplates(i_featTemp).uExpFeat,AllXexp(i_TrainData).template(i_featTemp).Xexp(i_token).ExpFeat));
            end
        end
    end
    i_Xexp{i_featTemp} = temp_i_xexp;
end

i_Xexp_train = i_Xexp;

%% test data
AllXexp = struct();
token_test = 0;
for i_TestData = 1 : size(ListTestData,1)
    % load a test data
    load(fullfile(RootPath,FolderData,'TestData',ListTestData(i_TestData).name)); %load as 'TestData'
    token_test = token_test + length(TestData.Xseq);
    fprintf('Evaluating the %d-th TestData... \n',i_TestData);
    % loops
    %  for each feature teamplate
    for i_featTemp = 1 : length(AEtemplates)
        for i_token = 1 : length(TestData.Xseq)+1
            % read expanded features
            tempExpFeat = '';
            for i_Exp = 1 : length(AEtemplates(i_featTemp).featExp)
                expXY = AEtemplates(i_featTemp).featExp{i_Exp};
                if expXY(1)+i_token < 1
                    tempExpFeat = [tempExpFeat, '/' ,'TokenOutOfUpperRange'];
                elseif expXY(1)+i_token > length(TestData.Xseq)
                    tempExpFeat = [tempExpFeat, '/' ,'TokenOutOfLowerRange'];
                else
                    if expXY(2) == 0
                        tempExpFeat = [tempExpFeat,'/',TestData.Wordseq{expXY(1)+i_token}];
                    elseif expXY(2) == 1
                        tempExpFeat = [tempExpFeat,'/',TestData.Xseq{expXY(1)+i_token}];
                    end
                end
            end
            % skip the extra '/' character in front of tempExpFeat
            tempExpFeat = tempExpFeat(2:end);
            AllXexp(i_TestData).template(i_featTemp).Xexp(i_token).ExpFeat = tempExpFeat;
        end
    end
end


for i_featTemp = 1 : length(AEtemplates)
    temp_i_xexp = zeros(1,token_test);
    posa=0;
    for i_TestData = 1 : size(ListTestData,1)
        % load a test data
        load(fullfile(RootPath,FolderData,'TestData',ListTestData(i_TestData).name)); %load as 'TestData'
        for i_token = 1 : length(TestData.Xseq)+1
            posa = posa + 1;
            
            if isempty(find(strcmp(AEtemplates(i_featTemp).uExpFeat,AllXexp(i_TestData).template(i_featTemp).Xexp(i_token).ExpFeat), 1))
                temp_i_xexp(1,posa) = 0;
            else
                temp_i_xexp(1,posa) = find(strcmp(AEtemplates(i_featTemp).uExpFeat,AllXexp(i_TestData).template(i_featTemp).Xexp(i_token).ExpFeat));
            end
        end
    end
    i_Xexp{i_featTemp} = temp_i_xexp;
end

i_Xexp_test = i_Xexp;

disp('done!');

%% generate feature index
fprintf('Generating feature index... ');
% read each AEtemplate, count Total Feature Number.
TotalFeat = 0;

% preallocate for better performance
FeatSeg = zeros(1,length(AEtemplates));

SegTmp = 0;
Ulist = [];
Blist = [];
for i_featTemp = 1 : length(AEtemplates)
    if strcmp(AEtemplates(i_featTemp).featType,'B')
        totalyfront = CRFmodel.Data.Ny;
    else
        totalyfront = 1;
    end
    TotalFeat = TotalFeat + length(AEtemplates(i_featTemp).uExpFeat)*CRFmodel.Data.Ny*totalyfront;
    FeatSeg(i_featTemp) = length(AEtemplates(i_featTemp).uExpFeat)*CRFmodel.Data.Ny*totalyfront + SegTmp;
    if strcmp(AEtemplates(i_featTemp).featType,'U')
        Ulist = [Ulist,SegTmp+1:FeatSeg(i_featTemp)];
    else
        Blist = [Blist,SegTmp+1:FeatSeg(i_featTemp)];
    end
    SegTmp = FeatSeg(i_featTemp);
end

pos = 1;
FFs=zeros(TotalFeat,3);
for i_featTemp = 1 : length(AEtemplates)
    % build FFs (feature function index)
    if strcmp(AEtemplates(i_featTemp).featType,'B')
        totalyfront = CRFmodel.Data.Ny;
        i_y_front = 1:totalyfront;
    else
        totalyfront = 1;
        i_y_front = 0;
    end
    
    i_y_front = repmat(i_y_front,length(AEtemplates(i_featTemp).uExpFeat)*CRFmodel.Data.Ny,1);
    i_y_front = reshape(i_y_front,length(AEtemplates(i_featTemp).uExpFeat)*CRFmodel.Data.Ny*totalyfront,1);
    i_y_rare = 1:CRFmodel.Data.Ny;
    i_y_rare = repmat(i_y_rare,length(AEtemplates(i_featTemp).uExpFeat),1);
    i_y_rare = reshape(i_y_rare,length(AEtemplates(i_featTemp).uExpFeat) * CRFmodel.Data.Ny,1);
    i_y_rare = repmat(i_y_rare,totalyfront);
    FFs(pos:FeatSeg(i_featTemp),1) = i_y_front;
    FFs(pos:FeatSeg(i_featTemp),2) = i_y_rare;
    FFs(pos:FeatSeg(i_featTemp),3) = repmat([1:length(AEtemplates(i_featTemp).uExpFeat)]',totalyfront * CRFmodel.Data.Ny,1);
    pos = pos + length(i_y_front);
end
disp('done!');
fprintf('%d feature functions had been created.\n',TotalFeat);
end