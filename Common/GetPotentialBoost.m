function SumPotential = GetPotentialBoost( CRFmodel, i_token, TrainData, i_y_front, i_y_rare )
%GETPOTENTIALBOOST boosted function for calculation of Potential
%   Inputs: CRFmodel, i_token, TrainData
%           i_y_front, i_y_rare
%   Output: SumPotential
%
%   Belongs to: Optimizer-Common
%
%   Last mod:   $19-Mar-2011 09:34:05$
%   Debug:  $19-Mar-2011 09:34:05$

%% main
SumPotential = 0;
tempPos = 1;
for i_featTemp = 1 : length (CRFmodel.AEtemplates)
    % extract the expanded feature: tempExpFeat
    tempExpFeat = '';
    for i_Exp = 1 : length(CRFmodel.AEtemplates(i_featTemp).featExp)
        expXY = CRFmodel.AEtemplates(i_featTemp).featExp{i_Exp};
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
    
    % check if tempExpFeat is existed in uExpFeat cell.
    if sum(strcmp(CRFmodel.AEtemplates(i_featTemp).uExpFeat,tempExpFeat)) >= 1
        
        % add up.
        if strcmp(CRFmodel.AEtemplates(i_featTemp).featType,'U')
            %             % Back Track to the index_feat of this 'active' feature...
            %             index_feat = BTrackFeat({y_rare}, tempExpFeat, CRFmodel, i_featTemp);
            i_xexp = find(strcmp(CRFmodel.AEtemplates(i_featTemp).uExpFeat,tempExpFeat),1);
            localPos = (i_y_rare-1)*(length(CRFmodel.AEtemplates(i_featTemp).uExpFeat))+i_xexp;
            if sum([0, i_y_rare, i_xexp] == CRFmodel.FFs(localPos+tempPos-1,:)) == 3
                index_feat = localPos+tempPos-1;
                SumPotential = SumPotential + sum(CRFmodel.ParamVector(index_feat));
            end
            
        else
            %             % Back Track to the index_feat of this 'active' feature...
            %             index_feat = BTrackFeat({y_front, y_rare}, tempExpFeat, CRFmodel, i_featTemp);
            % run a fast back track to find the index of current active feature
            i_xexp = find(strcmp(CRFmodel.AEtemplates(i_featTemp).uExpFeat,tempExpFeat),1);
            localPos = (i_y_front-1)*(CRFmodel.Data.Ny*length(CRFmodel.AEtemplates(i_featTemp).uExpFeat)) + (i_y_rare-1)*(length(CRFmodel.AEtemplates(i_featTemp).uExpFeat))+i_xexp;
            if sum([i_y_front, i_y_rare, i_xexp] == CRF.FFs(localPos+tempPos-1,:)) == 3
                index_feat = localPos+tempPos-1;
                SumPotential = SumPotential + sum(CRFmodel.ParamVector(index_feat));
            end
            
        end
        
        tempPos = CRFmodel.FeatSeg(i_featTemp) + 1;
    end
end

end