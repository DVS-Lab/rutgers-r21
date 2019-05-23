function [BetaReal BetaNuisance Ycorr D] = ModelRiskDataLinear(Data)
% ModelRiskData -- model data of risk experiment using GLM
%
% Regressors: *** PUT REGRESSORS OF INTEREST IN Data.Reg ***
% Nuisance regressors: 6 motion regessors, 1 linear trend, 1 constant
% Output: Betas, Ycorr (data corrected for regressors of no interest), D (design)
%
% Note: hrf not convolved with nuisance regressors
%--------------------------------------------------------------------------------

    % the data for our subject is in Data{sub} and consists of: (j enumerates sessions)
    %        Data{sub}.CSonset{j} = time of CSonset
    %        Data{sub}.USonset{j} = time of USonset
    %        Data{sub}.Trials{j}  = trial type
    %        Data{sub}.Rewards{j} = reward mag
    %        Data{sub}.Chosen{j}  = chosen CS
    %        Data{sub}.TDerr{j}   = TD error for every CS and US onset
    %        Data{sub}.TDtimes{j} = times of CSs and USs (TD events)
    %        Data{sub}.Motion{j}  = 6 columns motion parms: x, y, z, roll, pitch, yaw
    %        Data{sub}.fMRItimes{j} = the times we are interested in (the ones we have data for)
    %        Data{sub}.Reg{j}(N,:)= the N model regressors (not the nuisance parms)
    % NOTE:  all times are in 100ms resolution (we get this from dt)

    % create the hrf (taken from spm_hrf.m and spm_Gpdf -- computing Gamma through exp(log) for accuracy)
    % (originally hrf = spm_Gpdf(u,p(1)/p(2),dt/p(2)) - spm_Gpdf(u,p(3)/p(4),dt/p(4))/p(5))
    p = [6 1 16 1 6];              % the canonical HRF
    %   p(1) - shape parm for gamma 1	  (default 6)
    %	p(2) - scale parm for gamma 1     (default 1) (will be multiplied by dt)
    %	p(3) - shape parm for gamma 2     (default 16)
    %	p(4) - scale parm for gamma 2     (default 1) (will be multiplied by dt)
    %	p(5) - ratio of response to undershoot    (default 6)
    %	p(6) - onset (seconds)    (default 0sec) % not in use right now as we can't compute its derivative
    dt    = 0.1; ldt = log(dt);    % we need 10 ms resolution
    u     = [1:(32/dt)];           % these are the times we'll need (plus we'll need 0 -- tack it on later)
    gam1  = exp( (p(1)-1)*log(u) + p(1)*(log(p(2))+ldt) - u*p(2)*dt - gammaln(p(1)) ); 
    gam2  = exp( (p(3)-1)*log(u) + p(3)*(log(p(4))+ldt) - u*p(4)*dt - gammaln(p(3)) );
    hrf   = gam1 - gam2/p(5);
    hrf   = hrf'/(dt*sum(hrf));    % normalize the hrf to one 
    
    % creating the design matrix and fitting it for each session separately

    Nsessions = length(Data.CSonset);
    BetaNuisance = []; BetaReal = []; YcorrAll = []; DesignRealAll = [];
    Nreal = length(Data.Reg{1}(:,1));
    
    for j = 1:Nsessions
    
        Y = Data.TimeCourse{j}; L = length(Y);
        DesignNuisance = []; DesignReal = [];
        
        % we'll take a two step approach: model nuisance variables, get rid of them, 
        % and then model effects of interest 
        
        % nuisance regressors
        for n = 1:6
            DesignNuisance = [DesignNuisance Data.Motion{j}(:,n)-mean(Data.Motion{j}(:,n))];
        end
        % 3rd order, quadratic trend, linear trend and constant
        %Design(:,end+1) = (([1:L]/L).^3)'; Design(:,end) = Design(:,end) - mean(Design(:,end));
        DesignNuisance(:,end+1) = (([1:L]/L).^2)'; DesignNuisance(:,end) = DesignNuisance(:,end) - mean(DesignNuisance(:,end));
        DesignNuisance(:,end+1) = [1:L]/L'; DesignNuisance(:,end) = DesignNuisance(:,end) - mean(DesignNuisance(:,end));
        DesignNuisance(:,end+1) = ones(L,1);
        beta = regress(Y,DesignNuisance);
        BetaNuisance = [BetaNuisance; beta];
        
        Ycorr{j} = Y - DesignNuisance*beta;
        YcorrAll = [YcorrAll; Ycorr{j}];
        
        % real regressors
        for n = 1:Nreal
            % convolve the hrf with each of the the regressors then multiply by beta
            a = conv(hrf,Data.Reg{j}(n,:)); 
            % extracting only the timepoints we are intersted in
            a = a(Data.fMRItimes{j});
            DesignReal = [DesignReal a'-mean(a)];
        end
        DesignRealAll = [DesignRealAll;DesignReal];
        
        beta = regress(Ycorr{j},DesignReal);
        BetaReal = [BetaReal, beta];
        
        D{j}.Real = DesignReal;         % output the design matrix as well
        D{j}.Nuisance = DesignNuisance; 
        
    end
        
    % estimating the real regressors for all sessions at once (after we have corrected the
    % data for nuisance regressors)
    BetaReal = regress(YcorrAll,DesignRealAll);  %%!! comment/uncomment this line to get session-by-session betas!!