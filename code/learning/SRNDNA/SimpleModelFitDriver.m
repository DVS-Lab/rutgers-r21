load ModelingWorkshopData ; % the data to fit

Nsubjects = length(Data); 

clear Fit 
Fit.Nparms = 2;
Fit.LB = [0 1e-6];
Fit.UB = [1 30];

for s = 1:Nsubjects;
    fprintf('Fitting subject %d out of %d...\n',s,Nsubjects)
    % preprocessing the data a bit
    T = [Data{s}.Trials{1}  Data{s}.Trials{2}  Data{s}.Trials{3}];
    C = [Data{s}.Chosen{1}  Data{s}.Chosen{2}  Data{s}.Chosen{3}];
    R = [Data{s}.Rewards{1} Data{s}.Rewards{2} Data{s}.Rewards{3}];
    
    for iter = 1:5;   % run 5 times from random initial conditions, to get best fit
        fprintf('Iteration %d...\n',iter)
        
        % setting initial conditions
        Fit.init(s,iter,:) = rand(1,length(Fit.LB)).*(Fit.UB-Fit.LB)+Fit.LB; % random initialization
        
        % running fmincon to fit the free parameters of the model
        [res,lik] = ... 
            fmincon(@(x) FitSimpleTDModel_workshop(T,C,R,x(1),x(2)),...
            squeeze(Fit.init(s,iter,:)),[],[],[],[],Fit.LB,Fit.UB,[],...
            optimset('maxfunevals',5000,'maxiter',2000,'GradObj','off','DerivativeCheck','off','LargeScale','on','Algorithm','active-set'));
        % GradObj = 'on' to use gradients, 'off' to not use them *** ask us about this if you are interested *** 
        % DerivativeCheck = 'on' to have fminsearch compute derivatives numerically and check the ones I supply
        % LargeScale = 'on' to use large scale methods, 'off' to use medium
        Fit.Result.Eta(s,iter) = res(1); 
        Fit.Result.Beta(s,iter) = res(2); 
        Fit.Result.Lik(s,iter) = lik;
        Fit.Result.Lik  % to view progress so far
    end
    
end

% find the best fit results for each subject
[a,b] = min(Fit.Result.Lik,[],2);
for s = 1:Nsubjects
    Fit.Result.BestFit(s,:) = [s,...
    Fit.Result.Eta(s,b(s)),... 
    Fit.Result.Beta(s,b(s)),...
    Fit.Result.Lik(s,b(s))];
end
Fit.Result.BestFit