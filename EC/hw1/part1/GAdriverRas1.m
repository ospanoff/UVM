%SCRIPT FILE TO CALL GATOOLBOX FROM COMMAND WINDOW (TO SOLVE RASTRIGINSFCN)
% VERSION 1: SHOWS HOW TO SET OPTIONS AND CALL THE FUNCTION

% AUTHOR: MAGGIE EPPSTEIN

% SPECIFY ANY OPTIONS THAT ARE DIFFERENT FROM THE DEFAULTS
% (type "help gaoptimset" to see all the possible options)
myoptions=gaoptimset('PopInitRange',[-5;5],...
                    'PopulationSize',10,... %try rerunning with a larger population
                    'Generations',10,... %try rerunning with a longer number of generations
                    'StallGenLimit',inf,...
                    'StallTimeLimit',inf',...
                    'SelectionFcn',{@selectiontournament,4},... % TOURNEMENT SIZE PROVIDED
                    'CrossoverFcn',@crossoverarithmetic);
       
% NOW RUN THE GA ON A 2-VARIABLE RASTRIGINS FUNCTION WITH THESE OPTIONS
[bestsolution,bestfitness]=ga(@rastriginsfcn,2,myoptions) %LEAVE SEMICOLON OFF TO SEE RESULTS

% FOR FUN, LETS PLOT THE FUNCTION AND SEE WHERE THE BEST SOLUTION IS
% (NOTE: THE FOLLOWING CODE ONLY WORKS FOR 2-VARIABLE FUNCTIONS)
clf %clear the figure window
myezplot3d(@pcolor,@rastriginsfcn,-5,5); % pseudo-color plot over range <-5..5, -5..5>
hold on % we don't want to overwrite the plot, we want to add to it
plot3(bestsolution(1),bestsolution(2),bestfitness,'w*','markersize',10) % plot the best solution
title(['x=',num2str(bestsolution(1)),', y=',num2str(bestsolution(2))]) % display solution values
hold off % next time we run this we'll redraw it

