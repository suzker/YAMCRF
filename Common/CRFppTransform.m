function Nseq = CRFppTransform(config_file,sep_sign,NameTarget)
%CRFPPTRANSFORM Transform CRFpp train/test data to usable format
%   Input:  config_file, NameTarget(like 'test.data'), sep_sign(sign that seperate sequences, like ' ')
%   Output: Nseq(number of sequence)
%
%   * add special label before and after the sequence. (CRF_SPECIAL_START,
%   CRF_SPECIAL_START), X seq will not be extended accordinglly.
%   Last mod: $18-Mar-2011 21:45:03$
%   Debug: $18-Mar-2011 21:45:03$

%% Read file
eval(config_file);
file_path = fullfile(RootPath,FolderData,'RawData',NameTarget);
fid = fopen(file_path,'r');

%% Transfer...
Nseq = 0;

% cells to store seqs
if ~isempty(strfind(lower(NameTarget),'train'))
    TrainData.Xseq = cell(0,0);
    TrainData.Yseq = cell(0,0);
    TrainData.Wordseq = cell(0,0);
else
    TestData.Xseq = cell(0,0);
    TestData.Yseq = cell(0,0);
    TestData.Wordseq = cell(0,0);
end

while ~feof(fid)
    tLine = fgetl(fid);
    
    if ~isempty(tLine)
        XYW = strread(tLine,'%s','delimiter',sep_sign);
        if ~isempty(strfind(lower(NameTarget),'train'))
            TrainData.Wordseq(length(TrainData.Wordseq)+1) = XYW(1);
            TrainData.Xseq(length(TrainData.Xseq)+1) = XYW(2);
            TrainData.Yseq(length(TrainData.Yseq)+1) = XYW(3);
        else
            TestData.Wordseq(length(TestData.Wordseq)+1) = XYW(1);
            TestData.Xseq(length(TestData.Xseq)+1) = XYW(2);
            TestData.Yseq(length(TestData.Yseq)+1) = XYW(3);
        end
    else
        Nseq = Nseq + 1;
        % * SPECIAL LABEL
        if ~isempty(strfind(lower(NameTarget),'train'))
            TrainData.Yseq = ['CRF_SPECIAL_START',TrainData.Yseq,'CRF_SPECIAL_STOP'];
        else
            TestData.Yseq = ['CRF_SPECIAL_START',TestData.Yseq,'CRF_SPECIAL_STOP'];
        end
        %save a data file
        fprintf('Saving Data_%s.mat\n',prefZeros(Nseq,4));
        if ~isempty(strfind(lower(NameTarget),'train'))
            save (fullfile(RootPath,FolderData,'TrainData',['TrainData_',prefZeros(Nseq,4)]),'TrainData');
        else
            save (fullfile(RootPath,FolderData,'TestData',['TestData_',prefZeros(Nseq,4)]),'TestData');
        end
        % empty cells to store seqs
        if ~isempty(strfind(lower(NameTarget),'train'))
            TrainData.Xseq = cell(0,0);
            TrainData.Yseq = cell(0,0);
            TrainData.Wordseq = cell(0,0);
        else
            TestData.Xseq = cell(0,0);
            TestData.Yseq = cell(0,0);
            TestData.Wordseq = cell(0,0);
        end
    end
end

fclose(fid);
end