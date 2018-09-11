function mutants = mutate(population, parents, type_of_mutation)
% Ayat Ospanov and Eliot Heinrich
% Mutates the members of population specified by parents according to
% type_of_mutation
% population = population to be mutated (PxN array of ints)
% parents = vector of indices (array of ints)
% type_of_mutation = "swap" or "scramble" to choose algorithm of mutation
% Ex: m = mutate(1:15, [1,1,1], "swap")


[~, N] = size(population);
M = length(parents);
mutants = zeros(M, N);
for i = 1:M
    ix = parents(i);
    mutants(i, :) = population(ix, :);
    if type_of_mutation == "swap"
        k1 = randi(N);
        k2 = randi(N);

        tmp = mutants(i, k1);
        mutants(i, k1) = mutants(i, k2);
        mutants(i, k2) = tmp;
    elseif type_of_mutation == "scramble"
        len = randi(floor(N / 2));
        start_ix = randi(N - len);
        end_ix = start_ix + len;

        tmp = mutants(i, start_ix:end_ix);
        mutants(i, start_ix:end_ix) = tmp(randperm(length(tmp)));
    end
end
end
