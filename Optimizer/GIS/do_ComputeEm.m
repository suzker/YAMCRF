function EmV = do_ComputeEm( CRFmodel, TrainDataBundle ,HugeFB, ~ )
%DO_COMPUTEEM return expectation of all feature functions W.R.T model
%distribution. (BOOSTED!)
%   Input:  CRFmodel, HugeFB
%   Output: EmV
%
%   !Not functional for edge feature yet
%
%   Mod:    $28-Mar-2011 13:30:41$
%   Debug:  $25-Mar-2011 21:40:45$
%% init
EmV = ones(1,CRFmodel.TotalFeat);

Ntrain = length(TrainDataBundle);
Ntemp = length(CRFmodel.AEtemplates);

all_i_Xexp_node=cell(1,Ntemp);
all_i_Xexp_edge=cell(1,Ntemp);

% for node feature
postemp=0;
for i_TrainData = 1 : Ntrain
    for i_temp = 1 : Ntemp
        all_i_Xexp_node{i_temp}(postemp+1:postemp + length(TrainDataBundle(i_TrainData).Xseq),1) = CRFmodel.i_Xexp_train{i_temp}(1:length(TrainDataBundle(i_TrainData).Xseq));
        %shrink i_xseq_train
        CRFmodel.i_Xexp_train{i_temp} = CRFmodel.i_Xexp_train{i_temp}(length(TrainDataBundle(i_TrainData).Xseq)+2:end);
    end
    postemp = postemp + length(TrainDataBundle(i_TrainData).Xseq);
end

% for edge feature
all_i_Xexp_edge = CRFmodel.i_Xexp_train;

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

%% main
for i_feat = 1 : CRFmodel.TotalFeat;
    if temp_type(i_feat) == 1
        % for Unigram feature(node feature)
        fCondition = CRFmodel.FFs(i_feat,:);
        posXexp = find(all_i_Xexp_node{fCondition(4)}==CRFmodel.FFs(i_feat,3));
        posXexp = (posXexp-1).*CRFmodel.Data.Ny + fCondition(2);
        EmV(i_feat) = sum(HugeFB(posXexp));
    else
        % for Bigram feature(edge feature)
    end
end
end