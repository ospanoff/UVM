% This srcipt finds a population size for swap mutation
% that enables to reliably solve
% the 16-queens problem for 20 reps

options = gaoptimset('CreationFcn', @get_population, ...
                     'PopulationSize', 40, ...
                     'MutationFcn', @mutate_swap, ...
                     'Generations', 100, ...
                     'StallGenLimit', inf, ...
                     'StallTimeLimit', inf', ...
                     'SelectionFcn', {@selectiontournament, 4}, ...
                     'CrossoverFcn', @cut_and_crossfill, ...
                     'FitnessLimit', 0, ...
                     'CrossoverFraction', 0.2, ...
                     'EliteCount', 0, ...
                     'Display', 'off');

N = 16;
% range params for population sizes
MIN_POPSIZE = 200;
MAX_POPSIZE = 400;
STEP_POPSIZE = 10;
POPSIZES = MIN_POPSIZE:STEP_POPSIZE:MAX_POPSIZE;

nreps = 20;  % number of repeats
success_rate = zeros(length(POPSIZES), 1);

parfor i = 1:length(POPSIZES)
    fprintf('Pop. size = %d. ', POPSIZES(i));
    loop_opt = options;  % copy options as we do parallel iterations
    loop_opt.PopulationSize = POPSIZES(i);
    for rep = 1:nreps
        rng(rep);
        [bestsolution, bestfitness] = ga(@fitness, N, loop_opt);
        if bestfitness == 0
            success_rate(i) = success_rate(i) + 1;
        end
    end
    fprintf('Success rate = %d/%d\n', success_rate(i), nreps);
end

figure('position', [0, 0, 1600, 1000])
plot(POPSIZES, success_rate)
ylim([-inf, 21])  % thus we can see success_rate = 20 line
set(gca, 'fontsize', 24)
xlabel('Population size')
ylabel(sprintf('# of success runs out of %d', nreps))
title('Setting the Population Size for swap mutation')
