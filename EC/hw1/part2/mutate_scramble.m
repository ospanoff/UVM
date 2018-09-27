function mutants = mutate_scramble(parents, ~, ~, ~, ~, ~, population)
% Ayat Ospanov and Eliot Heinrich
% Mutates (scramble) the members of population specified by parents
% population = population to be mutated (PxN array of ints)
% parents = vector of indices (array of ints)
% Ex: m = mutate(1:15, [1,1,1])


[~, N] = size(population);
M = length(parents);
mutants = zeros(M, N);
for i = 1:M
    ix = parents(i);
    mutants(i, :) = population(ix, :);

    len = randi(floor(N / 2));
    start_ix = randi(N - len);
    end_ix = start_ix + len;

    tmp = mutants(i, start_ix:end_ix);
    mutants(i, start_ix:end_ix) = tmp(randperm(length(tmp)));
end
end
