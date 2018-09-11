function children = CutAndCrossfill(population, parents)
% Ayat Ospanov and Eliot Heinrich
% Generates a set of children using the alleles of population specified by
% parents
% population = population to generate children (PxN array of ints)
% parents = vector of indices (array of ints of length 2c)
% children = set of configurations specified by genome of parents (cxN
% array of ints)
% Ex: children = CutAndCrossfill([1:10; 1:10; 1:10], [1 2 2 3 2 3 1 3])


num_parents = length(parents) / 2;
[~, N] = size(population);
children = zeros(num_parents, N);
for i = 1:num_parents
    split = randi(N);
    ix1 = parents(2 * i - 1);
    ix2 = parents(2 * i);
    
    children(i, :) = population(ix1, :);
    child2 = population(ix2, :);
    
    ch2_ix = 1;
    for k = split:N
        while any(children(i, 1:k-1) == child2(ch2_ix))
            ch2_ix = ch2_ix + 1;
        end
        children(i, k) = child2(ch2_ix);
    end    
end
end
