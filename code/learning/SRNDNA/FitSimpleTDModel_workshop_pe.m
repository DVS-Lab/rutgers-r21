function PE = FitSimpleTDModel_workshop_pe(TrialType,CSchosen,Rewards,eta,beta)
% fprintf('Called with eta=%3.4f, beta = %3.4f \n',eta, beta) % DEBUG

% Find the log likelihood of the choice data under a TD model with learning rate
% eta, softmax temperature beta
% Outputs:
% Lik = - log likelihood of the data
% [derv = derivatives of the likelihood with respect to the different model
% parameters; -- ask us about this if you are interested]

lik    = 0;   % log likelihood

CS_num = [1 0;2 0;3 0;4 0;5 0;1 2;2 3;1 3;2 4;5 1;4 5]; % The stimuli (CSs) used for each trial type

V = zeros(1,5);  % initial values for the 5 stimuli

for t = 1:length(TrialType)  % t = trial number
    
    % the chosen stimulus (1 or 2 or 3 or 4 or 5)
    c = CSchosen(t);
    
    if ~isnan(c)            % this was a valid trial (missed trials: c = NaN)
        if (TrialType(t)>5) % this was a choice trial -- add it to the likelihood
            
            % the other (nonchosen) stimulus (also 1 to 5)
            n = sum(CS_num(TrialType(t),:)) - c;
            %fprintf('TrialType %d, Chosen %d (value %3.2f), not chosen %d (value %3.2f)\n',TrialType(t),c,V(c),n,V(n));
            
            % adding this choice to the log likelihood  
            k = beta * (V(c) - V(n));
            likelihood = 1/(1 + exp(-k));
            lik = lik + log(likelihood);

            % note -- use logsumexp (function) as it is a more stable function to do log(sum(exp()))

        end
        
        % updating the value of the chosen stimulus according to the reward received (on choice as well as single trials)
        PE(t) = Rewards(t) - V(c);
        V(c) = V(c) + eta*PE(t);
        
    end
end

% OPTIONAL: putting a prior on the parameters (so we are looking for the MAP and not the ML solution)
lik = lik + log(betapdf(eta,2,2));  % the prior on eta is a beta distrbution
lik = lik + log(gampdf(beta,2,3));  % the prior on beta is a gamma distribution

lik = -lik;  % so we can minimize the function rather than maximize