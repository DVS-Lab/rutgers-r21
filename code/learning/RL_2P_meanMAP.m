function result = RL_2P_meanMAP(choice, reward, trialtype)

%{

3. Slot Choice (1=pos; 2=neg; 3=neutral) ? shows which slot machine they choose
4. Reward (1=positive; 0.5=neutral; 0=negative) ? shows the outcome they actually got (e.g.,. positive money is a picture of 5 cents; neutral money is an empty circle; negative money is a picture of 5 cents with a red line through it)
    80% probability
5. Trial type (0=positive; 1=negative) ? positive trials have a choice of positive or neutral slot; negative trials have a choice of negative or neutral slot
    0 --> c = [1 3]; 1 --> c = [2 3];
6. Accuracy (1=correct response; 0=effort incorrect response).

%}

% mean MLE (alpha) and MAP (beta) estimates
alpha = 0.329410389;
beta = 5.695691278;

result.choice = choice;
result.reward = reward;
result.trialtype = trialtype;


b = [alpha beta];

%[b, loglike, exitflag, output, lambda, grad, H] = fmincon(@model, inx0, [],[],[],[],lb,ub,[], options, choice, reward);
[~, ~, cV, rpe] = model(b, choice, reward, trialtype); %finalizing best fitting model based on optimal alpha and beta
result.rpe = rpe; % reward prediction error for each trial
result.cV = cV; %expected/chosen value (maybe "stimulus value" according to Lin et al?)





function [loglike, V, cV, rpe] = model(x, choice, reward, trialtype)
%function to evaluate the loglikelihood of the model for parameters alpha
%and beta given the data

alpha = x(1); % avoid using matlab function names as variables (alpha and beta)
beta = x(2);
loglike = 0; % log likelihood

ntrial = length(choice);
V = zeros(ntrial,3); %columns: 1 (pos), 2 (neg), 3 (neu)
V(1,:) = [2 2 2]; %initializing at 2 (neutral); this could change.
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
        
        if trialtype(t) == 1 % choosing between 2 and 3 (negative)
            
            if c == 2
                
                k = beta * (V(t,2) - V(t,3));
                cV(t) = V(t,2);
                rpe(t) = reward(t) - V(t,2);
                V(t+1,2) = V(t,2) + alpha*rpe(t); %update chosen
                V(t+1,3) = V(t,3); %don't update
                V(t+1,1) = V(t,1); %don't update
                
            elseif c == 3
                
                k = beta * (V(t,3) - V(t,2));
                cV(t) = V(t,3);
                rpe(t) = reward(t) - V(t,3);
                V(t+1,3) = V(t,3) + alpha*rpe(t); %update chosen
                V(t+1,2) = V(t,2); %don't update
                V(t+1,1) = V(t,1); %don't update
                
            end
            
        elseif trialtype(t) == 0 % choosing between 1 and 3 (positive)
            
            if c == 1
                
                k = beta * (V(t,1) - V(t,3));
                cV(t) = V(t,1);
                rpe(t) = reward(t) - V(t,1);
                V(t+1,1) = V(t,1) + alpha*rpe(t); %update chosen
                V(t+1,2) = V(t,2); %don't update
                V(t+1,3) = V(t,3); %don't update
                
            elseif c == 3
                
                k = beta * (V(t,3) - V(t,1));
                cV(t) = V(t,3);
                rpe(t) = reward(t) - V(t,3);
                V(t+1,3) = V(t,3) + alpha*rpe(t); %update chosen
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
%loglike = loglike + log(betapdf(alpha,2,2));  % the prior on alpha is a beta distrbution
loglike = loglike + log(gampdf(beta,2,3));  % the prior on beta is a gamma distribution
%Rg = gamrnd(2,3,10000,1);
%figure,hist(Rg,100); title('gamma distribution (prior for inverse temperature');
%Rb = betarnd(2,2,10000,1);
%figure,hist(Rb,100); title('beta distribution (prior for learning rate)');

loglike = -loglike;  % so we can minimize the function rather than maximize.
% end: function [loglike, V, cV, rpe] = model(x, choice, reward, trialtype)

