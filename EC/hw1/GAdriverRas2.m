%SCRIPT FILE TO CALL GATOOLBOX FROM COMMAND WINDOW (TO SOLVE RASTRIGINSFCN)
% VERSION 2: 
%   A) SHOWS HOW TO CALL THE CUSTOM OUTPUT FUNCTION 
%   B) SHOWS HOW TO DO SOME SIMPLE PLOTTING OF THE GENERATIONAL STATS

% AUTHOR: MAGGIE EPPSTEIN

% SPECIFY ANY OPTIONS THAT ARE DIFFERENT FROM THE DEFAULTS
% (type "help gaoptimset" to see all the possible options)
myoptions=gaoptimset('PopInitRange',[-5.12;5.12],...
                    'PopulationSize',10,... %try rerunning with a larger population
                    'Generations',10,... %try a rerunning longer number of generations
                    'StallGenLimit',inf,...
                    'StallTimeLimit',inf',...
                    'SelectionFcn',{@selectiontournament,4},... 
                    'CrossoverFcn',@crossoverarithmetic,...
                    'OutputFcns',@gaoutputfcn); %CALL OUR CUSTOM OUTPUT FUNCTION
       
% NOW RUN THE GA ON A 2-VARIABLE RASTRIGINS FUNCTION WITH THESE OPTIONS
[bestsolution,bestfitness]=ga(@rastriginsfcn,2,myoptions) %leave off semicolon to display results

genstats = gaoutputfcn; % call the custom output function to retrieve generational statistics


figure(1),clf
% set(gcf,'position',[623 -59 331 573]);

% FOR FUN, LETS PLOT THE FUNCTION AND SEE WHERE THE BEST SOLUTION IS
% (NOTE: THE FOLLOWING CODE ONLY WORKS FOR 2-VARIABLE FUNCTIONS)
subplot(2,1,1)
myezplot3d(@pcolor,@rastriginsfcn,-5,5); % pseudo-color plot over range <-5..5, -5..5>
hold on % we don't want to overwrite the plot, we want to add to it
plot3(bestsolution(1),bestsolution(2),bestfitness,'w*','markersize',10) % plot the best solution
title(['x=',num2str(bestsolution(1)),', y=',num2str(bestsolution(2))]) % display solution values
hold off % next time we run this we'll redraw it

% LETS PLOT SOME OF THE GENERATIONAL STATISTICS ("help plot" to see plotting options)
subplot(2,1,2)
plot(genstats.WorstScore,'bo-')
hold on
plot(genstats.AvgScore,'g+-')
plot(genstats.BestScore,'r*-') 

% add some labels to the plot
legend('worst','average','best')
xlabel('generation')
ylabel('fitness')
title(['best guy found in generation ',num2str(genstats.LastImprovement)]);

