function population = get_population(N, ~, options)
% Ayat Ospanov and Eliot Heinrich
% Generates a population of P configurations of the N-queen problem
% Each row is a permuation of 1:N
% P = Number of configurations in population (int)
% N = Number of queens to generate (int)
% population = generated population (PxN array of ints)
% Ex: p = get_population(10, 5);

P = options.PopulationSize;

population = zeros(P, N);
for i = 1:P
    population(i, :) = randperm(N);
end
