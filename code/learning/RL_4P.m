function result = RL_4P(choice, reward, trialtype)

%{

3. Slot Choice (1=pos; 2=neg; 3=neutral) ? shows which slot machine they choose
4. Reward (1=positive; 0.5=neutral; 0=negative) ? shows the outcome they actually got (e.g.,. positive money is a picture of 5 cents; neutral money is an empty circle; negative money is a picture of 5 cents with a red line through it)
    80% probability
5. Trial type (0=positive; 1=negative) ? positive trials have a choice of positive or neutral slot; negative trials have a choice of negative or neutral slot
    0 --> c = [1 3]; 1 --> c = [2 3];
6. Accuracy (1=correct response; 0=effort incorrect response).

%}

% set upper and lower bounds for free parameters
lb = [0 0 0 1e-6];
ub = [1 1 1 30];

% set options for fmincon
options = optimset('Display','off','MaxIter',10000,'TolFun',1e-10,'TolX',1e-10,...
    'DiffMaxChange',1e-2,'DiffMinChange',1e-6,'MaxFunEvals',1000,'GradObj','off','DerivativeCheck','off','LargeScale','on','Algorithm','active-set');

result.choice = choice;
result.reward = reward;
result.trialtype = trialtype;
result.lb = lb;
result.ub = ub;
result.options = options;

reward2 = reward(11:end);
reward2(abs(reward2) > 3) = [];
nchoices = length(reward2);

for i = 1:10 % 10 iterations
    
    %random starting conditions; will interate 10 times and take best fit
    inx = rand(1,length(lb)).*(ub-lb)+lb;
    dof = length(inx);
    
    result.iter(i).inx = inx;
    
    %[b, loglike, exitflag, output, lambda, grad, H] = fmincon(@model, inx0, [],[],[],[],lb,ub,[], options, choice, reward);
    [b, loglike, exitflag, output, ~, ~, H] = fmincon(@model, inx, [],[],[],[],lb,ub,[], options, choice, reward, trialtype);
    se = transpose(sqrt(diag(inv(H))));
    result.iter(i).alpha1 = b(1); %learning rate
    result.iter(i).alpha1_se = se(1); %learning rate se
    result.iter(i).alpha2 = b(2); %learning rate
    result.iter(i).alpha2_se = se(2); %learning rate se
    result.iter(i).alpha3 = b(3); %learning rate
    result.iter(i).alpha3_se = se(3); %learning rate se
    result.iter(i).beta = b(4); %inverse temp param
    result.iter(i).beta_se = se(4); %inverse temp param se
    result.iter(i).modelLL = -loglike;
    result.iter(i).nullmodelLL = log(0.5)*nchoices; %LL of random-choice model
    result.iter(i).pseudoR2 = 1 + loglike/(result.iter(i).nullmodelLL); %pseudo-R2 statistic
    result.iter(i).BIC = 2 * loglike + (dof * log(nchoices));
    result.iter(i).AIC = 2 * loglike + (dof * 2);
    result.iter(i).exitflag = exitflag;
    result.iter(i).output = output;
    result.iter(i).H = H; %Hessian, make sure the MLE isn't near a boundary
    [~, ~, cV, rpe] = model(b, choice, reward, trialtype); %finalizing best fitting model based on optimal alpha and beta
    result.iter(i).rpe = rpe; % reward prediction error for each trial
    result.iter(i).cV = cV; %expected/chosen value (maybe "stimulus value" according to Lin et al?)
    
end

[~,I] = max([result.iter.modelLL]);
result.final = result.iter(I);



function [loglike, V, cV, rpe] = model(x, choice, reward, trialtype)
%function to evaluate the loglikelihood of the model for parameters alpha
%and beta given the data

alpha1 = x(1); % neg
alpha2 = x(2); % neu
alpha3 = x(3); % pos
beta = x(4);
loglike = 0; % log likelihood

ntrial = length(choice);
V = zeros(ntrial,3); %columns: 1 (pos), 2 (neg), 3 (neu)
V(1,:) = [0 0 0]; %initializing at 2 (neutral); this could change.
rpe = zeros(ntrial,1);
cV = zeros(ntrial,1);

for t = 1:ntrial
    
    % the chosen stimulus (1 or 2 or 3)
    c = choice(t);
    
    if c == -99 % ignore missed trials
        
        V(t+1,2) = V(t,2); %don't update
        V(t+1,3) = V(t,3); %don't update
        V(t+1,1) = V(t,1); %don't update
        rpe(t) = -99;
        cV(t) = -99;
        
    else
        
        if reward(t) == -1
            myalpha = alpha1;
        elseif reward(t) == 0
            myalpha = alpha2;
        elseif reward(t) == 1
            myalpha = alpha3;
        else
            disp('debugging...')
            keyboard
        end
        
        if trialtype(t) == 1 % choosing between 2 and 3 (negative)
            
            if c == 2
                
                k = beta * (V(t,2) - V(t,3));
                cV(t) = V(t,2);
                rpe(t) = reward(t) - V(t,2);
                V(t+1,2) = V(t,2) + myalpha*rpe(t); %update chosen
                V(t+1,3) = V(t,3); %don't update
                V(t+1,1) = V(t,1); %don't update
                
            elseif c == 3
                
                k = beta * (V(t,3) - V(t,2));
                cV(t) = V(t,3);
                rpe(t) = reward(t) - V(t,3);
                V(t+1,3) = V(t,3) + myalpha*rpe(t); %update chosen
                V(t+1,2) = V(t,2); %don't update
                V(t+1,1) = V(t,1); %don't update
                
            end
            
        elseif trialtype(t) == 0 % choosing between 1 and 3 (positive)
            
            if c == 1
                
                k = beta * (V(t,1) - V(t,3));
                cV(t) = V(t,1);
                rpe(t) = reward(t) - V(t,1);
                V(t+1,1) = V(t,1) + myalpha*rpe(t); %update chosen
                V(t+1,2) = V(t,2); %don't update
                V(t+1,3) = V(t,3); %don't update
                
            elseif c == 3
                
                k = beta * (V(t,3) - V(t,1));
                cV(t) = V(t,3);
                rpe(t) = reward(t) - V(t,3);
                V(t+1,3) = V(t,3) + myalpha*rpe(t); %update chosen
                V(t+1,2) = V(t,2); %don't update
                V(t+1,1) = V(t,1); %don't update
                
            end
        end
        
        %compute likelihood with softmax
        % wait till learning stabalizes
        if t > 10
            likelihood = 1/(1 + exp(-k));
            loglike = loglike + log(likelihood);
        end
        
        
    end
    
end
% OPTIONAL (from Yael Niv's workshop): putting a prior on the parameters (so we are looking for the MAP and not the ML solution)
%loglike = loglike + log(betapdf(alpha1,2,2));  % the prior on alpha is a beta distrbution
%loglike = loglike + log(betapdf(alpha2,2,2));  % the prior on alpha is a beta distrbution
%loglike = loglike + log(betapdf(alpha3,2,2));  % the prior on alpha is a beta distrbution
loglike = loglike + log(gampdf(beta,2,3));  % the prior on beta is a gamma distribution

loglike = -loglike;  % so we can minimize the function rather than maximize.
% end: function [loglike, V, cV, rpe] = model(x, choice, reward, trialtype)

