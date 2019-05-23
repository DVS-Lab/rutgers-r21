%{

Basic Models to test:
1) 2P standard RW with alpha and beta
2) 3P split alpha for pos/neg RPEs (not sure if this is "nested")

%}


clear;
maindir = pwd;
conditions = {'Money', 'Social'};
subjects = [1019 1020 1030 2001 2004 2005 2006 2007 2008];

for s = 1:length(subjects)
    subject = subjects(s);
    for c = 1:length(conditions)
        condition = conditions{c};
        %msg = sprintf('running subject %d on the %s condition',subject,condition);
        %disp(msg);
        
        if strcmp(condition,'Social')
            filename = fullfile(maindir,'data',['RP ' condition ' ' num2str(subject) '_rev_pb2.csv']);
        else
            filename = fullfile(maindir,'data',['RP ' condition ' ' num2str(subject) '_pb.csv']);
        end
        delimiter = ',';
        startRow = 2;

        % 1019_rev_pb2
        
        %% Format string for each line of text:
        %   column1: double (%f)
        %	column2: double (%f)
        %   column3: double (%f)
        %	column4: double (%f)
        %   column5: double (%f)
        %	column6: double (%f)
        % For more information, see the TEXTSCAN documentation.
        formatSpec = '%f%f%f%f%f%f%[^\n\r]';
        
        %% Open the text file and read in data
        fileID = fopen(filename,'r');
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
        fclose(fileID);
        
        
        %% Allocate imported array to column variable names
        Subject = dataArray{:, 1};
        Trial = dataArray{:, 2};
        SlotChoice = dataArray{:, 3};
        Reward = dataArray{:, 4};
        TrialType = dataArray{:, 5};
        Accuracy = dataArray{:, 6};
        
        if exist('BigReward','var')
            BigReward = [BigReward; Reward];
            BigTrialType = [BigTrialType; TrialType];
            BigSlotChoice = [BigSlotChoice; SlotChoice];
        else
            BigReward = Reward;
            BigTrialType = TrialType;
            BigSlotChoice = SlotChoice;
        end
    end
end
% scale rewards between 1 and 3
BigReward = (BigReward.*2) + 1;
BigReward = BigReward - 2;

%% run a fixed effects RL_2P model
result = RL_5P(BigSlotChoice, BigReward, BigTrialType);
result.final

