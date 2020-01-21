function [ fb_data ] = get_data(subj)
%fb_data(:,1) = choices (1,2,3)
%fb_data(:,2) = rewards (1,2,3)
%fb_data(:,3) = trial_num (1:72). omits all trials without feedback/reward

if ~ischar(subj)
    subj = num2str(subj);
end

try
    
    maindir = pwd;
    
    %first run
    a2_file = fullfile(maindir,subj,[ subj '_affectivefeedback_2.mat']);
    load(a2_file);
    a2_data = data;
    
    %second run
    a4_file = fullfile(maindir,subj,[ subj '_affectivefeedback_4.mat']);
    load(a4_file);
    a4_data = data;
    
    data = [a2_data a4_data];
    
    
    ntrials = length(data);
    
    trial_fb = zeros(ntrials,3); %deckchoice, fb_value, trialnum (misses have been removed)
    for i = 1:ntrials;
        trial_fb(i,3) = i;
        if data(i).lapse
            trial_fb(i,1) = 0;
            trial_fb(i,2) = 0;
        else
            trial_fb(i,1) = data(i).deckchoice;
            if data(i).noFB
                trial_fb(i,2) = 0;
            else
                trial_fb(i,2) = data(i).choice;
            end
        end
        
    end
    trial_fb(~trial_fb(:,1),:) = []; %remove lapses
    trial_fb(~trial_fb(:,2),:) = []; %remove no FB trials
    
    fb_data = trial_fb;
    
    
catch ME
    disp(ME.message)
    keyboard
end



