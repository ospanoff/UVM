function [xmin,bestfitness, timesofar,bestsofar,callsofar]=purecmaes2(fitnessfct,Nvars,maxevals,initbounds,flag)
% NOTE: this is a modification of the purecmaes code provided by Hansen.
% The code was modified by Maggie Eppstein to simplify certains things for a
% homework assignment in CS/CSYS 352.
%
% INPUTS:
% fitnessfct: the handle to the fitness function
% Nvars: the number of decision variables
% maxtime: maximum number of cpu seconds to run
% maxit: maximum number of iterations to run
% flag: controls method of covariance updates
%   1: use both rank 1 and rank mu updates
%   2: use rank 1 updates only
%   3: use rank mu updates only
%   4: use neither rank 1 more rank mu updates
% initbounds: 2-element vector that specifies initial range for decision vars
%
% OUTPUTS:
% xmin: best individual found
% bestfitness: fitness of best individual
% timesofar: vector of cumulative run time per each generation
% bestsofar: vector of best fitness in each generation
% callsofar: vector of number of fitness evaluations in each generation


% modification of the following version of purecmaes
% URL: http://www.lri.fr/~hansen/purecmaes.m
% (mu/mu_w, lambda)-CMA-ES
% CMA-ES: Evolution Strategy with Covariance Matrix Adaptation for
% nonlinear function minimization. To be used under the terms of the
% GNU General Public License (http://www.gnu.org/copyleft/gpl.html).
% Copyright: Nikolaus Hansen, 2003-09.
% e-mail: hansen[at]lri.fr
%
% This code is an excerpt from cmaes.m and implements the key parts
% of the algorithm. It is intendend to be used for READING and
% UNDERSTANDING the basic flow and all details of the CMA-ES
% *algorithm*. Use the cmaes.m code to run serious simulations: it
% is longer, but offers restarts, far better termination options,
% and supposedly quite useful output.
%


tic %start the timer
lambda = 4+floor(3*log(Nvars));  % population size, offspring number

% set up bookkeeping
maxit = ceil(maxevals/lambda)+1; %because we make and evaluate lambda kids each iteration (although we may exit early)
timesofar=nan(maxit,1);
bestsofar=nan(maxit,1);
callsofar=nan(maxit,1);
timesofar(1)=0;
stopfitness = 0;


xmean = rand(Nvars,1)*(initbounds(2)-initbounds(1))+initbounds(1);    % objective variables initial point
sigma = (initbounds(2)-initbounds(1))/2; % coordinate wise standard deviation (step size)

% Strategy parameter setting: Selection

mu = lambda/2;               % number of parents/points for recombination
weights = log(mu+1/2)-log(1:mu)'; % muXone array for weighted recombination
mu = floor(mu);
weights = weights/sum(weights);     % normalize recombination weights array
mueff=sum(weights)^2/sum(weights.^2); % effective population size

% Strategy parameter setting: Adaptation
cc = (4 + mueff/Nvars) / (Nvars+4 + 2*mueff/Nvars); % time constant for cumulation for C
cs = (mueff+2) / (Nvars+mueff+5);  % t-const for cumulation for sigma control

c1 = 2 / ((Nvars+1.3)^2+mueff);    % learning rate for rank-one update of C
cmu = 2 * (mueff-2+1/mueff) / ((Nvars+2)^2+mueff);  % and for rank-mu update

if flag==2 || flag == 4 % no rank mu update
    c1=c1+cmu;
    cmu=0;  
end

if flag>= 3 % no rank 1 mupdate
    cmu=cmu+c1;
    c1=0;
end

damps = 1 + 2*max(0, sqrt((mueff-1)/(Nvars+1))-1) + cs; % damping for sigma
% usually close to 1
% Initialize dynamic (internal) strategy parameters and constants
pc = zeros(Nvars,1); ps = zeros(Nvars,1);   % evolution paths for C and sigma
B = eye(Nvars,Nvars);                       % B defines the coordinate system
D = ones(Nvars,1);                      % diagonal D defines the scaling
C = B * diag(D.^2) * B';            % covariance matrix C
invsqrtC = B * diag(D.^-1) * B';    % C^-1/2
eigeneval = 0;                      % track update of B and D
chiN=Nvars^0.5*(1-1/(4*Nvars)+1/(21*Nvars^2));  % expectation of
%   ||N(0,I)|| == norm(randn(N,1))
%   out.dat = []; out.datx = [];  % for plotting output

% -------------------- Generation Loop --------------------------------
 
callsofar(1)=0;
counteval = 0;

arx=nan(Nvars,lambda);
arfitness=inf(lambda);

iter=1;
while counteval < maxevals && arfitness(1) > stopfitness % exit condition
    
    % Generate and evaluate lambda offspring
    for k=1:lambda,
        arx(:,k) = xmean + sigma * B * (D .* randn(Nvars,1)); % m + sig * Normal(0,C)
        arfitness(k) = fitnessfct(arx(:,k)'); % objective function call (I've transposed the individual to work with same fitness functions as DE does -MJE)
        counteval = counteval+1;
    end
    
    % Sort by fitness and compute weighted mean into xmean
    [arfitness, arindex] = sort(arfitness);  % minimization
    
    xold = xmean;
    xmean = arx(:,arindex(1:mu)) * weights;  % recombination, new mean value
    if any(isnan(xmean))||any(~isreal(xmean))
        break
    end
    bestx=xmean;
    % Cumulation: Update evolution paths
    ps = (1-cs) * ps ...
        + sqrt(cs*(2-cs)*mueff) * invsqrtC * (xmean-xold) / sigma;
    hsig = sum(ps.^2)/(1-(1-cs)^(2*counteval/lambda))/Nvars < 2 + 4/(Nvars+1);
    pc = (1-cc) * pc ...
        + hsig * sqrt(cc*(2-cc)*mueff) * (xmean-xold) / sigma;
    
    % Adapt covariance matrix C
    artmp = (1/sigma) * (arx(:,arindex(1:mu)) - repmat(xold,1,mu));  % mu difference vectors
    C = (1-c1-cmu) * C;                   % regard old matrix
    if c1>0
        hsig = sum(ps.^2)/(1-(1-cs)^(2*counteval/lambda))/Nvars < 2 + 4/(Nvars+1);
        pc = (1-cc) * pc ...
            + hsig * sqrt(cc*(2-cc)*mueff) * (xmean-xold) / sigma;
        C=C+c1 * (pc * pc' ...                % plus rank one update
            + (1-hsig) * cc*(2-cc) * C); % minor correction if hsig==0
    end
    if cmu > 0
        C=C+ cmu * artmp * diag(weights) * artmp'; % plus rank mu update
    end
    
    % Adapt step size sigma
    sigma = sigma * exp((cs/damps)*(norm(ps)/chiN - 1));
    
    % Update B and D from C
    if counteval - eigeneval > lambda/(c1+cmu)/Nvars/10  % to achieve O(N^2)
        eigeneval = counteval;
        C = triu(C) + triu(C,1)'; % enforce symmetry
        
        if isnan(C(1,1))
            break %abort
            warning('Exiting early since C is NaN')
        end
        [B,D] = eig(C);           % eigen decomposition, B==normalized eigenvectors
        D = sqrt(diag(D));        % D contains standard deviations now
        invsqrtC = B * diag(D.^-1) * B';
        Cold=C;
    end
    
    iter=iter+1;
    timesofar(iter)=toc; %keep track of runtime
    callsofar(iter)=counteval;
    if ~isnan(arfitness(1))
        bestsofar(iter)=arfitness(1);
    else
        bestsofar(iter)=bestsofar(iter-1);
    end 
    
end % while, end generation loop

% housekeeping
if isnan(timesofar(end))
    lastgen=find(isnan(timesofar),1,'first')-1;
else
    lastgen=length(timesofar);
end

bestsofar=bestsofar(1:lastgen);
timesofar=timesofar(1:lastgen);
callsofar=callsofar(1:lastgen);
xmin = bestx; % Return best point of last iteration.
bestfitness = bestsofar(end);
