%SCRIPT FILE TO CALL GATOOLBOX FROM COMMAND WINDOW (TO SOLVE RASTRIGINSFCN)
% VERSION 3: 
%   A) SHOWS HOW TO CALL THE FUNCTION MULTIPLE TIMES, 
%       (W OR W/O DIFFERENT OPTIONS)
%   B) SHOWS HOW TO AVERAGE OVER EACH RUN'S STATISTICS

% AUTHOR: MAGGIE EPPSTEIN

% SPECIFY ANY OPTIONS THAT ARE DIFFERENT FROM THE DEFAULTS
% (type "help gaoptimset" to see all the possible options)
myoptions=gaoptimset('PopInitRange',[-5.12;5.12],...
                    'Generations',500,... 
                    'StallGenLimit',inf,...
                    'StallTimeLimit',inf',...
                    'SelectionFcn',{@selectiontournament,4},... 
                    'CrossoverFcn',@crossoverarithmetic,...
                    'OutputFcns',@gaoutputfcn); %CALL OUR CUSTOM OUTPUT FUNCTION
     
popsizes=[10 100 1000]; %test 3 pop sizes
numreps=5; %do this many repetitions of each popsize (in general, use more reps than this!)

for p=1:length(popsizes) % for each of the 3 pop sizes
    myoptions.PopulationSize=popsizes(p); % can set an options field directly and leave others the same
    
    figure %make a new figure for this popsize
    for rep=1:numreps % repeat each population size numreps times
        % NOW RUN THE GA ON A 2-VARIABLE RASTRIGINS FUNCTION WITH THESE OPTIONS
        [bestsolution(rep,1:2),bestfitness(rep)]=ga(@rastriginsfcn,2,myoptions); % suppress display with semicolon
        genstats(rep) = gaoutputfcn; % call the custom output function to retrieve generational statistics
        
        %% PLOT ALL Best-in-generation REPS FOR THIS POPSIZE IN A NEW FIGURE        
        plot(genstats(rep).BestScore);
        hold on
    end %for each repetition
    xlabel('generations')
    ylabel('best fitness in each generation')
    title(['reps for popsize = ',num2str(popsizes(p))])
    hold off
    % NOW, DO SOME SUMMARY STATISTICS OVER ALL 10 REPS
    
    % find the best, worst, and avg of final best fitness for each of the 10 reps
    MeanofBest(p)=mean(bestfitness);
    BestofBest(p)=min(bestfitness); 
    WorstofBest(p)=max(bestfitness); 
    
    % find min,max,and avg of how long it took to find the best solution obtained
    % unfortunately, we have to use an explicit loop to do stats over structure array elements
    MeanofBestgen(p)=genstats(1).LastImprovement;
    BestofBestgen(p)=genstats(1).LastImprovement;   
    WorstofBestgen(p)=genstats(1).LastImprovement;    
    for rep=2:numreps
        nextvalue=genstats(rep).LastImprovement;
        MeanofBestgen(p)=MeanofBestgen(p)+nextvalue; % keep a running sum
        if nextvalue < BestofBestgen(p) % find value for rep that found it first
            BestofBestgen(p)=nextvalue;
        end
        if nextvalue > WorstofBestgen(p) % find value for rep that found it last
            WorstofBestgen(p)=nextvalue;
        end
    end
    MeanofBestgen(p)=MeanofBestgen(p)/numreps; % turn the sum into an average
        
end %for each popsize

figure %make a new figure for the summary statistics

subplot(2,1,1)
errorbar(popsizes,MeanofBest,(BestofBest-MeanofBest),(MeanofBest-WorstofBest),'r')
xlabel('population size')
ylabel('best fitness found ')
title(['min, avg, max of ',num2str(numreps), ' reps'])
ylim=get(gca,'ylim');
ylim(1)=-.1;
set(gca,'ylim',ylim); 

subplot(2,1,2)
errorbar(popsizes,MeanofBestgen,BestofBestgen-MeanofBestgen,MeanofBestgen-WorstofBestgen,'b')
xlabel('population size')
ylabel('#gens to best fitness found')
title(['min, avg, max of ',num2str(numreps), ' reps'])    
ylim=get(gca,'ylim');
ylim(1)=-10;
set(gca,'ylim',ylim); 
