function TestResult = Viterbi_main(config_file)
%VITERBI_MAIN Test task main entrance
% mod:      $20-Mar-2011 09:44:22$
% debug:    $27-Mar-2011 10:01:35$

%% init
diary off;
eval(config_file);

% load optimized parameter set
load(fullfile(RootPath,FolderData,'CRFmodel.mat')); % load as CRFmodel

TestResult.Decoder = 'Viterbi';
RecDirName = sprintf('Result-%s',CRFmodel.Time);
% record command window output
diary(fullfile(RootPath,FolderResult,RecDirName,'TestOuputs'));

%% main
% compute matrix M for test data with
do_ComputeM(config_file,CRFmodel, 'TestData',1);

% compute Forward factors for each test data
ListTestData = dir(fullfile(RootPath,FolderData,'TestData','*.mat'));
TotalTimeRight=0;
TotalToken=0;
load(fullfile(RootPath,FolderData,'MatrixM','allM_TestData.mat'));  %load as 'allM'
for i_TestData = 1 : length(ListTestData)
    fprintf('Decoding test data No. %d...',i_TestData);
    
    % load a test data
    load(fullfile(RootPath,FolderData,'TestData',ListTestData(i_TestData).name)); %load as 'TestData'
    lenSeq = length(TestData.Xseq);
    
    % computeFB.
    [FF, ~] = ComputeFB(allM(i_TestData).matrixM, CRFmodel, lenSeq);
    timeTimeRight = 0;
    tempYseqPredict = cell(1,lenSeq+2);
    tempYseqPredict{1} = 'CRF_SPECIAL_START';
    tempYseqPredict{lenSeq+2} = 'CRF_SPECIAL_STOP';
    tempiYseqPredict = zeros(1,lenSeq);
    % Find maximum local labels
    for i_token = 1 : lenSeq
        [~,index_y_max] = max(FF{i_token+1});
        tempiYseqPredict(i_token) = index_y_max;
        tempYseqPredict{i_token+1} = CRFmodel.Data.Ytype{index_y_max};
    end
    tempTimeRight = sum(strcmp(tempYseqPredict,TestData.Yseq));
    
    TempAccuracy = (tempTimeRight) / (lenSeq + 2) * 100;
    TotalTimeRight = TotalTimeRight + tempTimeRight;
    TotalToken = TotalToken + lenSeq + 2;
    
    fprintf('Accuracy for current test: %.3f %%... ',TempAccuracy);
    
    % Test Result
    TestResult.TestData(i_TestData).PredictYseq = tempYseqPredict;
    TestResult.TestData(i_TestData).PredictiYseq = tempiYseqPredict;
    TestResult.TestData(i_TestData).OriYseq = TestData.Yseq;
    TestResult.TestData(i_TestData).Xseq = TestData.Xseq;
    TestResult.TestData(i_TestData).Wordseq = TestData.Wordseq;
    TestResult.TestData(i_TestData).accuracy = TempAccuracy;
    disp('done!');
end

TestResult.TotalTimeRight = TotalTimeRight;
TestResult.TotalToken = TotalToken;
TestResult.AvAccuracy = (TotalTimeRight/TotalToken)*100;
fprintf('Average Accuracy: %.3f %%\n',TestResult.AvAccuracy);

diary off;

% save TestResult
save(fullfile(RootPath,FolderResult,RecDirName,sprintf('result-%s.mat',CRFmodel.Time)),'TestResult');
end

