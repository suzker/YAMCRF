function [Ny, Nx, Xtype, Ytype, TokenTotal, TrainTotal] = do_ProcData(config_file)
%DO_PROCDATA Process Data and Return detailed statistics of Datas.
%   Input: config_file
%   Output: Ny - number of types of Ylabel
%           Nx - number of types of Xdata
%           Xtype, Ytype
%   Latest mod: $mar 05, 2011; 10:57$
%   Debuged:    $mar 11, 2011; 17:18$

%% Initialization
eval(config_file);

%% Main

fprintf('Processing data...');

% prepare cells to store Xtype and Ytype name
Xtype = cell(0,0);
Ytype = cell(0,0);

% list all train data pair
ListTrainData = dir(fullfile(RootPath,FolderData,'TrainData','*.mat'));
TokenTotal = 0;
TrainTotal = length(ListTrainData);

for i_TrainData = 1 : TrainTotal
    % load a train data
    load(fullfile(RootPath,FolderData,'TrainData',ListTrainData(i_TrainData).name)); %load as 'TrainData'
    
    % remvoe duplicate cells to boost the speed
    uniqueXseq = unique(TrainData.Xseq);
    uniqueYseq = unique(TrainData.Yseq);
    
    Xtype = unique([Xtype, uniqueXseq]);
    Ytype = unique([Ytype, uniqueYseq]);
    
    TrainDataBundle(i_TrainData).Xseq = TrainData.Xseq;
    TrainDataBundle(i_TrainData).Yseq = TrainData.Yseq;
    TrainDataBundle(i_TrainData).Wordseq = TrainData.Wordseq;
    TokenTotal = TokenTotal + length(TrainData.Xseq);
end

for i_TrainData = 1 : TrainTotal
    % load a train data
    load(fullfile(RootPath,FolderData,'TrainData',ListTrainData(i_TrainData).name)); %load as 'TrainData'
    
    TrainDataBundle(i_TrainData).i_Yseq = zeros(1,length(TrainData.Yseq));
    for i_token = 1 : length(TrainData.Yseq)
        TrainDataBundle(i_TrainData).i_Yseq(1,i_token) = find(strcmp(TrainDataBundle(i_TrainData).Yseq{1,i_token},Ytype));
    end
end

save(fullfile(RootPath,FolderData,'TrainDataBundle.mat'),'TrainDataBundle');

% count Nx and Ny
Nx = length(Xtype);
Ny = length(Ytype);

disp(' done!');
Nx
Ny
end

