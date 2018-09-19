% This srcipt compares two mutation functions (swap and scramble)
% by comparing avg best fitness for nreps runs at each generation
% for 16 queens problem
% population size is fixed to POPSIZE

N = 16;
POPSIZE = 600;
GENSIZE = 100;

options = gaoptimset('CreationFcn', @get_population, ...
                     'PopulationSize', POPSIZE, ...
                     'MutationFcn', @mutate_swap, ...
                     'Generations', GENSIZE, ...
                     'StallGenLimit', inf, ...
                     'StallTimeLimit', inf', ...
                     'SelectionFcn', {@selectiontournament, 4}, ...
                     'CrossoverFcn', @cut_and_crossfill, ...
                     'FitnessLimit', 0, ...
                     'CrossoverFraction', 0.2, ...
                     'EliteCount', 0, ...
                     'Display', 'off', ...
                     'OutputFcns', @gaoutputfcn);

nreps = 20;  % number of repeats
avg_fitness = zeros(GENSIZE, 2);  % average fitness over repeats

for rep = 1:nreps
    rng(rep);

    % do swap mutation
    options.MutationFcn = @mutate_swap;
    ga(@fitness, N, options);
    bestScores = gaoutputfcn;
    bestScores = bestScores.BestScore;
    avg_fitness(1:length(bestScores), 1) = ...
        avg_fitness(1:length(bestScores), 1)...
        + bestScores;

    % do scramble mutation
    options.MutationFcn = @mutate_scramble;
    ga(@fitness, N, options);
    bestScores = gaoutputfcn;
    bestScores = bestScores.BestScore;
    avg_fitness(1:length(bestScores), 2) = ...
        avg_fitness(1:length(bestScores), 2)...
        + bestScores;
end

% count average fitness by dividing by nreps as we summed up in the loop
avg_fitness = avg_fitness / nreps;

% plot avg fitnesses
figure('position', [0, 0, 1600, 1000])
plot(avg_fitness)
ylim([-0.5, inf])  % thus we can see fitness = 0 line
set(gca, 'fontsize', 24)
xlabel('Generation')
ylabel(sprintf('Avg. best fitness for %d runs', nreps))
title('Swap vs Scramble mutation')
legend({'swap','scramble'}, 'Location', 'best')
