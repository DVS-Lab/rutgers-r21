% create regressors for neural data
% everything is saved in Data which looks like this:
%        the data for each subject is in Data{sub} and consists of: (j enumerates sessions)
%        Data{sub}.CSonset{j} = time of CSonset
%        Data{sub}.USonset{j} = time of USonset
%        Data{sub}.Trials{j}  = trial type
%        Data{sub}.Rewards{j} = reward mag
%        Data{sub}.Chosen{j}  = chosen CS
%        Data{sub}.TDerr{j}   = TD error for every CS and US onset
%        Data{sub}.TDtimes{j} = times of CSs and USs (TD events)
%        Data{sub}.Motion{j}  = 6 columns motion parms: x, y, z, roll, pitch, yaw
%        Data{sub}.TimeCourse{j} = the fMRI data
%        Data{sub}.fMRItimes{j}  = the times we are interested in (the ones we have data for)
%        Data{sub}.Reg{j}(N,:)= the N model regressors
% NOTE:  all times are in 100ms resolution!

load Data 
Nsubjects = length(subjects);
Nsessions = 3;

for sub = 1:Nsubjects
    
    % Model the behavioral data with TD
    T = [Data{s}.Trials{1}  Data{s}.Trials{2}  Data{s}.Trials{3}];
    C = [Data{s}.Chosen{1}  Data{s}.Chosen{2}  Data{s}.Chosen{3}];
    R = [Data{s}.Rewards{1} Data{s}.Rewards{2} Data{s}.Rewards{3}];
    
    [x TDerror] = FitSimpleTDmodel_workshop_pe(T,C,R,***model parms here***); 
    
    TDerror.CS(isnan(TDerror.CS)) = 0; % getting rid of the NaNs and treating them as simply no error
    TDerror.US(isnan(TDerror.US)) = 0;
    TDerr = reshape([TDerror.CS; TDerror.US],156,3); % reshaping into three sessions
    
    % Creating regressors for this subject: TDerr, CStimes, UStimes, USmag all in 10ms
    % resolution
    % NOTE: don't forget that all these may include NANs!!!    
    for j = 1:Nsessions
        base = zeros(1,Data{sub}.fMRItimes{j}(end)); % we start with zeros in each dt timebin until the end of the scan 

        Data{sub}.RName{1} = 'TD err';  
        Data{sub}.Reg{j}(1,:) = base;
        Data{sub}.Reg{j}(1,Data{sub}.TDtimes{j}) = Data{sub}.TDerr(:,j)';

        Data{sub}.RName{2} = 'US onset';
        Data{sub}.Reg{j}(2,:) = base; 
        Data{sub}.Reg{j}(2,Data{sub}.USonset{j}(~isnan(Data{sub}.Chosen{j}))) = 1;
        
        Data{sub}.RName{3} = 'CS onset';
        Data{sub}.Reg{j}(3,:) = base;
        Data{sub}.Reg{j}(3,Data{sub}.CSonset{j}) = 1;
        
        Data{sub}.RName{4} = 'US mag';
        Data{sub}.Reg{j}(4,:) = base;
        Data{sub}.Reg{j}(4,Data{sub}.USonset{j}) = Data{sub}.Rewards{j};

    end
end

save(sprintf('%s_AllEventsDataRevision',VOI_name),'Data','dt')