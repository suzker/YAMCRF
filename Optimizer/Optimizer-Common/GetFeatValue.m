function BinValue = GetFeatValue(i_feat, i_y_input, i_x_exp, CRFmodel)
%GETFEATVALUE Return a value according to the index of featrue 'i_feat' and
%current token 'i_token', y_front(y_rare), Xseq
%   Inputs: 'i_feat' index of current feature
%           'i_y_input' a matrix including 'i_y_rare' and may be 'i_y_front'. when
%           only 1 element found in 'Yinput', it will be treated as 'i_y_rare'.
%           if 'i_y_input' is a 2x2 matrix: [i_y_front, i_y_rare]
%           'i_x_exp'  index of current x expanded feature
%           CRFmodel
%   Output: 'BinValue'  a binary feature function value
%
%   Last mod: $mar 15, 2011; 21:24$
%   debug:  $mar 13, 2011; 11:07$

%% main
%这段可以在外面算好，重复了。
% if length(Y_input) > 1
%     i_y_front = find(strcmp(CRFmodel.Data.Ytype, Y_input{1}),1);
%     i_y_rare = find(strcmp(CRFmodel.Data.Ytype, Y_input{2}),1);
% else
%     i_y_rare = find(strcmp(CRFmodel.Data.Ytype, Y_input{1}),1);
% end

% 这段可以放到每个token循环处，避免重复运算。
% FeatCount=0;
% % extract expanded feature of xseq
% for i_featTemp = 1 : length(CRFmodel.AEtemplates)
%     FeatCount = FeatCount + CRFmodel.FeatSeg(i_featTemp);
%     if i_feat <= FeatCount
%         TempPointer = i_featTemp;
%         break;
%     end
% end
% 
% i_featTemp = TempPointer;
% % extract the expanded feature: tempExpFeat
% tempExpFeat = '';
% for i_Exp = 1 : length(CRFmodel.AEtemplates(i_featTemp).featExp)
%     expXY = CRFmodel.AEtemplates(i_featTemp).featExp{i_Exp};
%     if expXY(1)+i_token < 1
%         tempExpFeat = [tempExpFeat, '/' ,'TokenOutOfUpperRange'];
%     elseif expXY(1)+i_token > length(TrainData.Xseq)
%         tempExpFeat = [tempExpFeat, '/' ,'TokenOutOfLowerRange'];
%     else
%         if expXY(2) == 0
%             tempExpFeat = [tempExpFeat,'/',TrainData.Wordseq{expXY(1)+i_token}];
%         elseif expXY(2) == 1
%             tempExpFeat = [tempExpFeat,'/',TrainData.Xseq{expXY(1)+i_token}];
%         end
%     end
% end
% % skip the extra '/' character in front of tempExpFeat
% tempExpFeat = tempExpFeat(2:end);
% 
% i_x_exp = find(strcmp(CRFmodel.AEtemplates(TempPointer).uExpFeat,tempExpFeat),1);

funCondition = CRFmodel.FFs(i_feat,:);

% output
if length(i_y_input) > 1
    if i_y_input(1) == funCondition(1) && i_y_input(2) == funCondition(2) && i_x_exp == funCondition(3)
        BinValue = 1;
    else
        BinValue = 0;
    end
else
    if i_y_input(1) == funCondition(2) && i_x_exp == funCondition(3)
        BinValue = 1;
    else
        BinValue = 0;
    end
end
end

