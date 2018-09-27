function mutants = mutate_swap(parents, ~, ~, ~, ~, ~, population)
% Ayat Ospanov and Eliot Heinrich
% Mutates (swap) the members of population specified by parents
% population = population to be mutated (PxN array of ints)
% parents = vector of indices (array of ints)
% Ex: m = mutate(1:15, [1,1,1])


[~, N] = size(population);
M = length(parents);
mutants = zeros(M, N);
for i = 1:M
    ix = parents(i);
    mutants(i, :) = population(ix, :);

    k1 = randi(N);
    indices = [1:k1-1 k1+1:N];  % drop generated index so that k2 != k1
    k2 = indices(randi(N-1));

    tmp = mutants(i, k1);
    mutants(i, k1) = mutants(i, k2);
    mutants(i, k2) = tmp;
end
end
