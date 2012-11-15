function EeV = do_ComputeEe(CRFmodel, TrainDataBundle)
%DO_COMPUTEEE Return the expectation of feat' func' W.R.T emperical
%distribution. (BOOSTED!)
%   Input: CRFmodel, TrainDataBundle
%   Output: EeV
%
%   !Not functional for edge feature yet
%
%   Mod:    $28-Mar-2011 14:41:31$
%   Debug:  $28-Mar-2011 14:41:31$

%% init
fprintf('Computing expectation of feat func W.R.T emperical distribution... ');
EeV = ones(1,CRFmodel.TotalFeat);

Ntemp = length(CRFmodel.AEtemplates);

% add the template info into the original FFs vector
FeatCount=0;
temp_count = zeros(CRFmodel.TotalFeat,1);
temp_type = zeros(CRFmodel.TotalFeat,1);
for i_featTemp = 1 : Ntemp
    temp_count(FeatCount+1:CRFmodel.FeatSeg(i_featTemp),1) = i_featTemp;
    if strcmp(CRFmodel.AEtemplates(i_featTemp).featType,'U')
        temp_type(FeatCount+1:CRFmodel.FeatSeg(i_featTemp),1) = 1;
    else
        temp_type(FeatCount+1:CRFmodel.FeatSeg(i_featTemp),1) = 0;
    end
    FeatCount = CRFmodel.FeatSeg(i_featTemp);
end
CRFmodel.FFs = [CRFmodel.FFs,temp_count];

Ntrain = length(TrainDataBundle);
all_i_Yexp_node=zeros(CRFmodel.Data.TokenTotal,2);
all_i_Yexp_edge=zeros(CRFmodel.Data.TokenTotal+Ntrain,3);
all_i_Xexp_node=cell(1,Ntemp);
all_i_Xexp_edge=cell(1,Ntemp);
for i_temp = 1 : Ntemp
    all_i_Xexp_node{i_temp}=zeros(CRFmodel.Data.TokenTotal,1);
    all_i_Xexp_edge{i_temp}=zeros(CRFmodel.Data.TokenTotal+Ntrain,1);
end

% for edge feature
postemp=0;
for i_TrainData = 1 : Ntrain
    all_i_Yexp_edge(postemp+1:postemp + length(TrainDataBundle(i_TrainData).Xseq) + 1,1) = TrainDataBundle(i_TrainData).i_Yseq(1:end-1);
    all_i_Yexp_edge(postemp+1:postemp + length(TrainDataBundle(i_TrainData).Xseq) + 1,2) = TrainDataBundle(i_TrainData).i_Yseq(2:end);
    all_i_Yexp_edge(postemp+1:postemp + length(TrainDataBundle(i_TrainData).Xseq) + 1,3) = i_TrainData;
    postemp = postemp + length(TrainDataBundle(i_TrainData).Xseq) + 1;
end
all_i_Xexp_edge = CRFmodel.i_Xexp_train;

% for node feature
postemp=0;
for i_TrainData = 1 : Ntrain
    all_i_Yexp_node(postemp+1:postemp + length(TrainDataBundle(i_TrainData).Xseq),1) = TrainDataBundle(i_TrainData).i_Yseq(2:end-1);
    all_i_Yexp_node(postemp+1:postemp + length(TrainDataBundle(i_TrainData).Xseq),2) = i_TrainData;
    for i_temp = 1 : Ntemp
        all_i_Xexp_node{i_temp}(postemp+1:postemp + length(TrainDataBundle(i_TrainData).Xseq),1) = CRFmodel.i_Xexp_train{i_temp}(1:length(TrainDataBundle(i_TrainData).Xseq));
        %shrink i_xseq_train
        CRFmodel.i_Xexp_train{i_temp} = CRFmodel.i_Xexp_train{i_temp}(length(TrainDataBundle(i_TrainData).Xseq)+2:end);
    end
    postemp = postemp + length(TrainDataBundle(i_TrainData).Xseq);
end

%% main
for i_feat = 1 : CRFmodel.TotalFeat;
    if temp_type(i_feat) == 1
        % for Unigram feature(node feature)
        fCondition = CRFmodel.FFs(i_feat,:);
        all_emprical = [all_i_Yexp_node(:,1),all_i_Xexp_node{fCondition(4)}];
        %   very slow command:
        %         sameCondition = ismember(all_emprical, fCondition(2:3),'rows');
        %   faster command:
        sameCondition = fix(sum(repmat(fCondition(2:3),length(all_emprical),1) == all_emprical,2)./2);
        resultList = sameCondition .* all_i_Yexp_node(:,2);
        uniqueIndex = unique(resultList);
        % uniqueIndex will including unexpected 0s, so we have to do...
        % length(uniqueIndex)-1
        tempEe = 0;
        for i_unique = 1:length(uniqueIndex)-1
            tempEe = tempEe + length(find(resultList == uniqueIndex(i_unique+1)))* ...
                CRFmodel.Data.Pejxy(uniqueIndex(i_unique+1));
        end
        EeV(i_feat) = tempEe;
    else
        % for Bigram feature(edge feature)
    end
end
disp('done!');
end

