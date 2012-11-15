function avAccuracy = CRFppResultTransform(config_file, sep_sign ,ResultName)
%CRFPPRESULTTRANSFORM Transform a CRFpp test result into cell and compute
%it's accuracy for current task.
%   use this (unix)command:
%       $>> crf_test -m model test.data > result.data
%   to output a result.data file to your home folder, then copy it to the
%   YAMCRF's RawData folder.
%
%   Input:  config_file
%           sep_sign:   '	'
%           ResultName: 'result.data'
%
%   Output: accuracy
%
%   Example:    avAccuracy = CRFppResultTransform(config_file, '	' , 'result.data')
%
%   MOD:    $20-Mar-2011 11:37:17$
%   Debug:  $20-Mar-2011 11:49:48$

%% init
eval(config_file);
file_path = fullfile(RootPath,FolderData,'RawData',ResultName);
fid = fopen(file_path,'r');

%% main
Nseq = 0;

TotalTimeRight = 0;
TotalToken = 0;

TestResult.Xseq = cell(0,0);
TestResult.Yseq = cell(0,0);
TestResult.PreYseq = cell(0,0);
TestResult.Wordseq = cell(0,0);

while ~feof(fid)
    tLine = fgetl(fid);
    
    if ~isempty(tLine)
        WXYP = strread(tLine,'%s','delimiter', sep_sign);
        TestResult.Wordseq(length(TestResult.Wordseq)+1) = WXYP(1);
        TestResult.Xseq(length(TestResult.Xseq)+1) = WXYP(2);
        TestResult.Yseq(length(TestResult.Yseq)+1) = WXYP(3);
        TestResult.PreYseq(length(TestResult.PreYseq)+1) = WXYP(4);
    else
        Nseq = Nseq + 1;
        TestResult.Yseq = ['CRF_SPECIAL_START',TestResult.Yseq,'CRF_SPECIAL_STOP'];
        TestResult.PreYseq = ['CRF_SPECIAL_START',TestResult.PreYseq,'CRF_SPECIAL_STOP'];
        TempTimeRight = sum(strcmp(TestResult.Yseq,TestResult.PreYseq));
        lenYSeq = length(TestResult.Yseq);
        TempAccuracy = TempTimeRight / lenYSeq*100;
        fprintf('Accuracy for %d-th test: %.3f %%... \n',Nseq,TempAccuracy);
        TotalTimeRight = TotalTimeRight + TempTimeRight;
        TotalToken = TotalToken + lenYSeq;
    end
end

avAccuracy = TotalTimeRight / TotalToken * 100;
fprintf('Average accuracy for all test data is: %.3f %%\n',avAccuracy);

end
