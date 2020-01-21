function result = RL_2P_David_Robust(choice, reward, inx)

% Inputs:
%   INX - starting values for alpha and beta
%   CHOICE - a vector of choices (i.e. 1, 2, 3, etc)
%   REWARD - a vector of rewards (smaller rewards help model converge
%            better - keep in mind, such as diving reward to maintain single digits
%
% Outputs:
%   RESULT - a struct the data and all information return by the model fitting procedure
%
% Adopted from Robb Rutledge's original RL_2P script
% Khoi D. Vo
% March 10, 2015

if nargin == 2
    inx = [0.01, 1]; %initial parameters that I found to work very well on first pass. If anything, will need to optimize beta initial param (second param) - KDV
end

% consider doing grid search to get optimal initial points
lb = [0 1e-6]; %lower limits for alpha and beta
ub = [1 inf]; %upper limits

options = optimset('Display','off','MaxIter',10000,'TolFun',1e-10,'TolX',1e-10,...
    'DiffMaxChange',1e-2,'DiffMinChange',1e-6,'MaxFunEvals',1000,'GradObj','off','DerivativeCheck','off','LargeScale','on','Algorithm','active-set');
warning off;
dof = length(inx);

result.choice = choice;
result.reward = reward;
result.inx = inx;
result.lb = lb;
result.ub = ub;
result.options = options;

try
    inx0 = inx;
    [b, loglike, exitflag, output, lambda, grad, H] = fmincon(@model, inx0, [],[],[],[],lb,ub,[], options, choice, reward);
    se = transpose(sqrt(diag(inv(H))));
    result.alpha = b(1); %learning rate
    result.alpha_se = se(1); %learning rate se
    result.beta = b(2); %inverse noise param
    result.beta_se = se(2); %inverse noise param se
    result.modelLL = -loglike; %taking negative of loglike gives model's log(likelihood) 
    result.nullmodelLL = log(0.33)*size(choice,1); %LL of random-choice model
    result.pseudoR2 = 1 + loglike/(result.nullmodelLL); %pseudo-R2 statistic
    result.BIC = 2 * loglike + (dof * log(size(choice,1)));
    result.AIC = 2 * loglike + (dof * 2);
    result.exitflag = exitflag;
    result.output = output;
    result.H = H; %Hessian, sometimes bad and se smaller than they should be
    [loglike, probchoice, weight,ll] = model(b, choice, reward); %finalizing best fitting model based on optimal alpha and beta
    result.probchoice = probchoice; %prob of choosing option c where probchoice is a (n x c) matrix given n trials and c choices
    result.weight = weight; %model fits Q-values for each trial where weight is a (n x c) matrix given n trials and c choices
    result.ll = ll; %loglikelihood of each trial after each update given choice
catch lasterr
    result.modelLL = 0;
    result.exitflag = 0;
end;

function [loglike, probchoice, weight,ll] = model(x, choice, reward)

%function to evaluate the loglikelihood of the model for parameters alpha
%and beta given the data

alpha = x(1);
beta = x(2);

weight = weight_singlealpha(choice, reward, alpha); %compute the weights
[loglike, probchoice,ll] = eval_loglike(choice, weight, beta,alpha); %compute the likelihood

function [loglike, probchoice,ll] = eval_loglike(choice, weight, beta, alpha)

%[loglike, probchoice] = eval_loglike(choice, weight, beta)
%
%Inputs: 
%   CHOICE - a vector of choices with 1s for choices to option 1 (choices
%      to option 2 could be 0s or 2s or whatever).
%   WEIGHT - a matrix with 2 columns of weights, all >=0, computed using
%      the standard Q-learning model. The first column is the weights for
%      option 1 and the second is the weights for option 2.
%   BETA - a noise parameter, the inverse temperature.
%
%Outputs:
%   LOGLIKE - the total (negative) loglikelihood of a model given the
%      player's choices, the Q-learning model weight matrix, and the
%      player's noise parameter.
%   PROBCHOICE - a vector with the probability of choosing option 1 on each
%      trial according to the model.
%
% Adopted from Robb Rutledge's original RL_2P script
% Khoi D. Vo
% March 10, 2015

loglike = 0;   % log likelihood
for t = 1:length(choice) 
    % the chosen stimulus (1 or 2 or 3)
    c = choice(t);
    
    % all available options
    ctemp = [1,2,3];
    
    % remove chosen option
    ctemp(c) = [];
    
    % probchoice for chosen option given weight - logodds
    probchoice(t,c) = exp(beta*weight(t,c))/(exp(beta*weight(t,c)) + exp(beta*weight(t,ctemp(1))) + exp(beta*weight(t,ctemp(2))));
    
    % log(probchoice)
    llupdate(t,1) = beta*weight(t,c) - log(exp(beta*weight(t,c)) + exp(beta*weight(t,ctemp(1))) + exp(beta*weight(t,ctemp(2)))); % compute log odds of choice for each trial
    
    % update log(likelihood)
    loglike = loglike + llupdate(t,1);
    
    % record log(likelihood)
    ll(t,1) = loglike;
end

% OPTIONAL: putting a prior on the parameters (so we are looking for the
% MAP and not the ML solution) - from Yael Niv - use if you believe this is
% the correct prior distribution
%
% loglike = loglike + log(betapdf(alpha,2,2));  % the prior on alpha is a beta distrbution
% loglike = loglike + log(gampdf(beta,2,3));  % the prior on beta is a gamma distribution

loglike = -loglike;  % so we can minimize the function rather than maximize. Will be reversed in the results saving above by taking -loglike

function [weight] = weight_singlealpha(choice, reward, alpha)

%[weights] = qlearning_model(choice, reward, alpha_con, alpha_pat)
%
% Inputs:
%   CHOICE - a vector of choices with 1s for choices to option 1 (choices
%      to option 2 could be 0s or 2s or whatever).
%   REWARD - a vector of rewards with 1s for rewarded and -1s for unrewarded
%      trials.
%   ALPHA - the learning rate parameter
%
%       subINFO - this is important for when you are running more than one
%       participant's data. For instance, if you are running a dataset that
%       contains the choice information of 2 or more participants, you will
%       need to have the information of that participant in this cell. Is
%       your choice & reward is let's say 90 trials long, then you will
%       need to repeat the participant's information for 90 rows with the
%       first column as the participant ID and the second column is an
%       additional identifier of participant's group. If all your
%       participants are in the same group, just use the same identifier
%       number.
%
% Outputs: 
%   WEIGHT - a matrix with 2 columns of weights, all >=0, computed using
%      the standard Q-learning model. The first column is the weights for
%      option 1 and the second is the weights for option 2. Weights are
%      initiated as 0s.
%
% Adopted from Robb Rutledge's original RL_2P script
% Khoi D. Vo
% March 10, 2015

ntrial = length(choice);
rpe = zeros(length(choice));
weight = zeros(ntrial,3); %assume 0 for starting conditions (could assume otherwise)

for n = 1:ntrial-1
    c = choice(n);
    
    % all available options
    u = [1,2,3];
    
    % remove chosen option
    u(c) = [];
    
    rpe(n) = reward(n) - weight(n,c); %compute rpe
    weight(n+1,c) = weight(n,c) + alpha*rpe(n); %update chosen
    weight(n+1,u(1)) = weight(n,u(1)); %unchosen option 1 not updated but carried over from previous trial
    weight(n+1,u(2)) = weight(n,u(2)); %unchosen option 2 not updated but carried over from previous trial
end