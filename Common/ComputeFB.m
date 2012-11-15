function [FF,BF] = ComputeFB(matrixM, CRFmodel, lenSeq)
%COMPUTEFB Return the Forward factor 'FF' and Backward factor 'BF'
%   Input: matrixM, CRFmodel, lenSeq(length of target sequence)
%   Output: FF, BF
%
%   last mod:   $13-Mar-2011 15:25:02$
%   debug:      $27-Mar-2011 18:01:06$

%% main
% label(last but one) = 'CRF_SPECIL_START'
% label(last one) = 'CRF_SPECIL_STOP'
FF = cell(lenSeq+1,1);
BF = cell(lenSeq+1,1);

%   special FF
FF{1} = strcmp(CRFmodel.Data.Ytype,'CRF_SPECIAL_START')';
%   special BF
BF{lenSeq+1} = strcmp(CRFmodel.Data.Ytype,'CRF_SPECIAL_STOP')';

%   general..
for i = 2 : lenSeq+1
    FF{i} = (FF{i-1}' * matrixM{i-1})';
end
for i = lenSeq+1 : -1 : 2
    BF{i-1} = matrixM{i} * BF{i};
end
BF=BF';
end