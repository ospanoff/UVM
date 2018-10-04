function [FVr_bestmem,S_bestval,timesofar,bestsofar,callsofar] = deopt_rand_1_bin(fname,Nvars,maxnevals,initbounds,flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS IS A MODIFICATION OF DE, TO ONLY IMPLEMENT DE/rand/1/bin
% The code was modified by Maggie Eppstein to simplify the interface for a
% homework assignment in CS/CSYS 352. I've hard-coded a bunch of things here to make your lives
% easier, but in general you would want to set these options yourself.
%
% INPUTS:
% fname: function handle for fitness function
% Nvars: number of decision variables in the problem
% I_itermax: exit when we've hit this many generations(or when we find optimum of 0)
% initbounds: 2-element vector specifying [minval maxval] for the initial random decision variables in the pop
% flag: if flag ==1, use F = 0.85, else use random F in 0.5 to 1.2 for each difference vector this multiplies
%
% OUTPUTS:
% FVr_bestmem: best individual found
% S_bestval: fitness of best individual
% timesofar: vector of cumulative run time per each generation
% bestsofar: vector of best fitness in each generation
% callsofar: vector of number of fitness evaluations in each generation


% This is a modification of the following
%
% Function:         [FVr_bestmem,S_bestval,I_nfeval] = deopt(fname,S_struct)
%                    
% Author:           Rainer Storn, Ken Price, Arnold Neumaier, Jim Van Zandt
% Note:
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 1, or (at your option)
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details. A copy of the GNU 
% General Public License can be obtained from the 
% Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic %stop the timer
% PREALLOCATE BOOKKEEPING VECTORS TO AVOID DYNAMICALLY GROWING VECTORS
I_NP         = 10*Nvars; % could be 5-10 times Nvars
I_itermax = ceil(maxnevals/I_NP)+1; %because we make and evaluate I_NP kids each iteration

timesofar=nan(I_itermax,1);
bestsofar=nan(I_itermax,1);
callsofar=nan(I_itermax,1);
timesofar(1)=0;
callsofar(1)=0;
stopfitness = 0; %note: this may be different for different fitness functions!

if flag==1
    F_weight = 0.85;
else
    F_weight = nan; % choose F randomly
end
F_CR         = 0.5; %scattered crossover prob for picking allele for trial vector from mutant vector
I_D          = Nvars;
FVr_minbound = initbounds(1)+zeros(1,I_D);
FVr_maxbound = initbounds(2)+zeros(1,I_D);
I_bnd_constr = false;
tolerance   = nan;


FVr_rot  = (0:1:I_NP-1);               % rotating index array (size I_NP)


%-----Check input variables---------------------------------------------
if (I_NP < 5)
    I_NP=5;
    fprintf(1,' I_NP increased to minimal value 5\n');
end
if ((F_CR < 0) || (F_CR > 2))
    F_CR=0.9;
    fprintf(1,'F_CR should be from interval [0,1]; set to default value 0.9\n');
end
if (I_itermax <= 0)
    I_itermax = 200;
    fprintf(1,'I_itermax should be > 0; set to default value 200\n');
end

%-----Initialize population and some arrays-------------------------------
FM_pop = zeros(I_NP,I_D); %initialize FM_pop to gain speed

%----FM_pop is a matrix of size I_NPx(I_D+1). It will be initialized------
%----with random values between the min and max values of the-------------
%----parameters-----------------------------------------------------------

for k=1:I_NP
    FM_pop(k,:) = FVr_minbound + rand(1,I_D).*(FVr_maxbound - FVr_minbound);
end

%------Evaluate the best member after initialization----------------------

I_best_index   = 1;                   % start with first population member
S_val(1)       = fname(FM_pop(I_best_index,:));
I_nfeval      = 0;                    % number of function evaluations

S_bestval = S_val(1);                 % best objective function value so far

for k=2:I_NP                          % check the remaining members
    S_val(k)  = fname(FM_pop(k,:));
    I_nfeval  = I_nfeval + 1;
    if (S_val(k)<S_bestval)
        I_best_index   = k;              % save its location
        S_bestval      = S_val(k);
    end
end

FVr_bestmem = FM_pop(I_best_index,:);            % best member ever
bestsofar(1)=S_bestval;

FVr_ind  = zeros(4);
FM_meanv = ones(I_NP,I_D);
I_iter = 1;


while (I_iter < I_itermax) && (S_bestval > stopfitness)
    FM_popold = FM_pop;                  % save the old population
    
    FVr_ind = randperm(I_NP-1,3);                 % 3 random offsets by how much to rotate
    
    FVr_a1  = randperm(I_NP);                   % shuffle locations of vectors
    FVr_rt  = rem(FVr_rot+FVr_ind(1),I_NP);     % rotate indices by ind(1) positions
    FVr_a2  = FVr_a1(FVr_rt+1);                 % rotate vector locations
    FVr_rt  = rem(FVr_rot+FVr_ind(2),I_NP);     % rotate indices by ind(2) positions
    FVr_a3  = FVr_a1(FVr_rt+1);                 % rotate vector locations
    
    if FVr_a1(1)==FVr_a2(1) || FVr_a2(1)==FVr_a3(1) || FVr_a1(1)==FVr_a3(1)
        keyboard
    end
    
    FM_pm1 = FM_popold(FVr_a1,:);             % shuffled population 1
    FM_pm2 = FM_popold(FVr_a2,:);             % shuffled population 2
    FM_pm3 = FM_popold(FVr_a3,:);             % shuffled population 3
    
    
    FM_mui = rand(I_NP,I_D) < F_CR;  % all random numbers < F_CR are 1, 0 otherwise
    
    FM_mpo = ~FM_mui;    % inverse mask to FM_mui
    
    % DE/rand/1
    if ~isnan(F_weight) %if prespecified scaling factor
        FM_ui = FM_pm3 + F_weight*(FM_pm1 - FM_pm2);   % differential variation
    else % use random scaling values between .5 and 1.2 for each difference vector
        F_random=rand(size(FM_pm1))*.7+.5; 
        FM_ui = FM_pm3 + F_random.*(FM_pm1 - FM_pm2);   % differential variation
    end
    FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;     % crossover
    FM_origin = FM_pm3;
    
    
   
    %-----Select which vectors are allowed to enter the new population------------
    for k=1:I_NP
        
        %=====Only use this if boundary constraints are needed==================
        if (I_bnd_constr == 1)
            for j=1:I_D %----boundary constraints via bounce back-------
                if (FM_ui(k,j) > FVr_maxbound(j))
                    FM_ui(k,j) = FVr_maxbound(j) + rand*(FM_origin(k,j) - FVr_maxbound(j));
                end
                if (FM_ui(k,j) < FVr_minbound(j))
                    FM_ui(k,j) = FVr_minbound(j) + rand*(FM_origin(k,j) - FVr_minbound(j));
                end
            end
        end
        %=====End boundary constraints==========================================
        
        S_tempval = fname(FM_ui(k,:));   % check cost of competitor

        
        if S_tempval<=S_val(k) %if new guy is better or equal
            FM_pop(k,:) = FM_ui(k,:);                    % replace old vector with new one (for new iteration)
            S_val(k)   = S_tempval;                      % save value in "cost array"
            
            %----we update S_bestval only in case of success to save time-----------
            if (S_tempval<S_bestval)
                S_bestval = S_tempval ;                   % new best value
                FVr_bestmem = FM_ui(k,:);                 % new best parameter vector ever
                
            end
        end
    end % for k = 1:NP
    I_nfeval = I_nfeval+I_NP;
    
 
    I_iter = I_iter + 1;
    timesofar(I_iter)=toc; %TIME THIS GENERATION
    bestsofar(I_iter)=S_bestval;
    callsofar(I_iter)=I_nfeval;
    
    
    if ~isnan(tolerance)
        vecdiff=zeros(size(FM_pop));
        for param=1:I_D
            vecdiff(:,param)=vecdiff(:,param)+abs(FM_pop(1,param)-FM_pop(:,param));
        end
        if  max(vecdiff(:))< S_struct.tolerance
            break
        end
    end
end % while

% TRUNCATE EXCESS FROM BOOKKEEPING VECTORS
if isnan(timesofar(end))
    lastgen=find(isnan(timesofar),1,'first')-1;
else
    lastgen=length(timesofar);
end
bestsofar=bestsofar(1:lastgen);
timesofar=timesofar(1:lastgen);
callsofar=callsofar(1:lastgen);
