% This srcipt compares two mutation functions (swap and scramble)
% by comparing success rate over population sizes
% for 16 queens problem

options = gaoptimset('CreationFcn', @get_population, ...
                     'PopulationSize', 10, ...
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
MIN_POPSIZE = 100;
MAX_POPSIZE = 2000;
STEP_POPSIZE = 50;
POPSIZES = MIN_POPSIZE:STEP_POPSIZE:MAX_POPSIZE;

nreps = 20;  % number of repeats
success_rates = zeros(length(POPSIZES), 2);

parfor i = 1:length(POPSIZES)
    fprintf('Pop. size = %d\n', POPSIZES(i));
    loop_opt = options;  % copy options as we do parallel iterations
    loop_opt.PopulationSize = POPSIZES(i);

    for rep = 1:nreps
        rng(rep);

        % do swap mutation
        loop_opt.MutationFcn = @mutate_swap;
        [~, bestfitness_swap] = ga(@fitness, N, loop_opt);

        % do scramble mutation
        loop_opt.MutationFcn = @mutate_scramble;
        [~, bestfitness_scr] = ga(@fitness, N, loop_opt);

        success_rates(i, :) = success_rates(i, :) ...
            + [bestfitness_swap == 0, bestfitness_scr == 0];
    end
end

% plot success rates
figure('position', [0, 0, 1600, 1000])
plot(POPSIZES, success_rates)
ylim([-inf, nreps + 1])  % thus we can see success_rate = 20 line
set(gca, 'fontsize', 24)
xlabel('Population size')
ylabel(sprintf('# of success runs out of %d', nreps))
title('Swap vs Scramble mutation')
legend({'swap','scramble'}, 'Location', 'best')
