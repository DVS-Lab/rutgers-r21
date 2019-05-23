clear;
maindir = pwd;
conditions = {'Money', 'Social'};
subjects = [1019 1020 1030 2001 2004 2005 2006 2007 2008];

fid_summary = fopen(fullfile(maindir,'summary_2P.csv'),'w');
fprintf(fid_summary,'subject,condition,alpha,alpha_se,beta,beta_se,psuedoR2,BIC\n');
for s = 1:length(subjects)
    subject = subjects(s);
    for c = 1:length(conditions)
        condition = conditions{c};
        msg = sprintf('running subject %d on the %s condition',subject,condition);
        disp(msg);
        
        filename = fullfile(maindir,'data',['RP ' condition ' ' num2str(subject) '_pb.csv']);
        delimiter = ',';
        startRow = 2;
        
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
        
        % scale rewards between 1 and 3 
        Reward = (Reward.*2) + 1;
        
        %% run RL_2P model and save results
        result = RL_2P(SlotChoice, Reward, TrialType);
        
        %fprintf(fid_summary,'subject,condition,alpha,alpha_se,beta,beta_se,psuedoR2,BIC\n');
        R = result.final;
        fprintf(fid_summary,'%d,%s,%f,%f,%f,%f,%f,%f\n',subject,condition,R.alpha,R.alpha_se,R.beta,R.beta_se,R.pseudoR2,R.BIC);
        
        fid_subj = fopen(fullfile(maindir,['rpe_' num2str(subject) '_' condition '_2P.csv']),'w');
        fprintf(fid_subj,'subject,trial,slotchoice,reward,ExpectedValue,RPE\n');
        for t = 1:length(Reward)
            fprintf(fid_subj,'%d,%d,%d,%d,%f,%f\n',subject,t,SlotChoice(t),Reward(t),R.cV(t),R.rpe(t));
        end
        fclose(fid_subj);
    end
end
fclose(fid_summary);
