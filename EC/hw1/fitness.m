function values = fitness(population)
% Ayat Ospanov and Eliot Heinrich
% Finds number of conflicts for a population of configurations of the
% N-queens problem
% population = population of configurations to be evaluated (PxN array of
% ints)
% values = fitness of each individual in the population (array of ints of
% length P)
% Ex: f = fitness([1 2 3 4; 4 2 1 3; 1 3 2 4])

[P, N] = size(population);
values = zeros(P, 1);
for k = 1:P
    for i = 1:N
        j = i+1:N;
        eq = j - i == abs(population(k, j) - population(k, i));
        values(k) = values(k) + sum(eq);
            
    end
end
end

