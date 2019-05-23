function Fit = RL_2P_DaveSmith()

% getting data directories
mainDir = uigetdir(pwd,'Choose data directory');
try
    dstore = get_any_files('.DS_Store',mainDir);
    for i = 1:length(dstore)
        delete(dstore{i});
    end
catch
end
dirData = dir(mainDir);     
dirIndex = [dirData.isdir];  
subDirs = {dirData(dirIndex).name};  
validIndex = ~ismember(subDirs,{'.','..'});
batchList = {dirData(validIndex).name};

Fit.NParams = 2;
Fit.LB = [0 1e-6];
Fit.UB = [1 inf];

for s = 1:length(batchList);
    % preprocessing the data a bit
    data = get_data(mainDir,batchList{s});
    choice = data(:,1);
    rewards = data(:,2);
    
    nullmodelLL = log(0.33)*size(choice,1); %LL of random-choice model

    for iter = 1:5;   % run 5 times from random initial conditions, to get best fit        
        % determining initial condition
        Fit.init(s,iter,1) = 0.01;
        Fit.init(s,iter,2) = 1;
        
        % running fmincon to fit the free parameters of the model
        [res,loglike,exitflag,output,lambda,grad,H] = ... 
            fmincon(@(x) Fit_2P(choice,rewards,x(1),x(2)),...
            squeeze(Fit.init(s,iter,:)),[],[],[],[],Fit.LB,Fit.UB,[],...
            optimset('maxfunevals',10000,'maxiter',1000,'GradObj','off','DerivativeCheck','off','LargeScale','on','Algorithm','active-set'));
        % GradObj = 'on' to use gradients, 'off' to not use them *** ask us about this if you are interested *** 
        % DerivativeCheck = 'on' to have fminsearch compute derivatives numerically and check the ones I supply
        % LargeScale = 'on' to use large scale methods, 'off' to use medium
        
        Fit.Result.Eta(s,iter) = res(1); 
        Fit.Result.Beta(s,iter) = res(2); 
        Fit.Result.Loglike(s,iter) = loglike;
        Fit.Result.pseudoR2(s,iter) = 1 + loglike/(nullmodelLL); %pseudo-R2 statistic        
    end
end

% find the best fit results for each subject
[a,b] = min(Fit.Result.Loglike,[],2);
for s = 1:length(batchList)
    Fit.Result.BestFit(s,:) = [s,...
                               Fit.Result.Eta(s,b(s)),... 
                               Fit.Result.Beta(s,b(s)),...
                               Fit.Result.Loglike(s,b(s)),...
                               Fit.Result.pseudoR2(s,b(s))];
end
Fit.Result.BestFit

function likelihood = Fit_2P(choice,reward,eta,beta)
% fprintf('Called with eta=%3.4f, beta = %3.4f \n',eta, beta) % DEBUG

% Find the log likelihood of the choice data under a TD model with learning rate
% eta, softmax temperature beta
% Outputs:
% Lik = - log likelihood of the data
% [derv = derivatives of the likelihood with respect to the different model
% parameters; -- ask us about this if you are interested]

V = zeros(1,3);  % initial values for the 5 stimuli
likelihood = 0;   % log likelihood

for t = 1:length(choice)  % t = trial number
    
    % the chosen stimulus (1 or 2 or 3 or 4 or 5)
    c = choice(t);
    
    % all available options
    ctemp = [1,2,3];
    
    % remove chosen option
    ctemp(c) = [];
    
    % update likelihood based on chosen and unchosen options - this is the
    % log likelihood update
    %
    % P(choice | Q(chosen), Q(unchosen 1), Q(unchosen 2) = 
    % exp(beta * Q(chosen)) / sum(exp(beta * Q(Chosen, Unchosen 1, Unchosen
    % 2)
    % llupdate = log(P(choice)). Taking the log allows us to get rid of the
    % exp in the numerator. In the denominator, we cannot get rid of the
    % exp because we have to do the sum. Using log rules, we can do
    % subtraction of numerator and denominator.
    
    llupdate = beta*V(c) - log(exp(beta*V(c)) + exp(beta*V(ctemp(1))) + exp(beta*V(ctemp(2))));
    
    % adding this choice to the log likelihood
    likelihood = likelihood + llupdate;
    
    % updating the value of the chosen stimulus according to the reward received (on choice as well as single trials)
    PE = reward(t) - V(c);
    V(c) = V(c) + eta*PE;
end

% OPTIONAL: putting a prior on the parameters (so we are looking for the MAP and not the ML solution)
%likelihood = likelihood + log(betapdf(eta,2,2));  % the prior on eta is a beta distrbution
%likelihood = likelihood + log(gampdf(beta,2,3));  % the prior on beta is a gamma distribution

likelihood = -likelihood;  % so we can minimize the function rather than maximize

function fb_data = get_data(maindir,subj)
%fb_data(:,1) = choices (1,2,3)
%fb_data(:,2) = rewards (1,2,3)
%fb_data(:,3) = trial_num (1:72). omits all trials without feedback/reward

if ~ischar(subj)
    subj = num2str(subj);
end

try
        
    
    if rem(subnum,2) %odd
        %first run
        a1_file = fullfile(maindir,subj,[ subj '_affectivefeedback_1.mat']);
        load(a1_file);
        a1_data = data;
        %second run
        a3_file = fullfile(maindir,subj,[ subj '_affectivefeedback_3.mat']);
        load(a3_file);
        a3_data = data;
        data = [a1_data a3_data];
    else %even
        %first run
        a2_file = fullfile(maindir,subj,[ subj '_affectivefeedback_2.mat']);
        load(a2_file);
        a2_data = data;
        %second run
        a4_file = fullfile(maindir,subj,[ subj '_affectivefeedback_4.mat']);
        load(a4_file);
        a4_data = data;
        data = [a2_data a4_data];
    end
    
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
    trial_fb(~trial_fb(:,1),:) = [];
    trial_fb(~trial_fb(:,2),:) = [];
    
    fb_data = trial_fb;
    
    
catch ME
    disp(ME.message)
    keyboard
end



