get_population(1,1) % 1x1 array containing only 1
get_population(10, 5) % 10x5 array containing numbers 1-5
get_population(5, 10) % 5x10 array containing numbers 1-10

mutate([1 2; 1 2; 1 2], [1,2,3],"swap") % Each row has a 50% chance of being flipped from 1 2 to 2 1
mutate([1 2 3 4], [1,1,1,1],"swap") % Mutate this one individual 4 times
mutate([1 2 3 4], [1,1,1,1],"scramble") % Should allow for more than 2 alleles to be mutated

CutAndCrossfill([1:10; [6:10, 1:5]],[1 1 2 2 1 2]) % First two children should be the same as first two parents
CutAndCrossfill([1:10; 10:-1:1],[1 2 1 2 2 1])

fitness([1 2 3 4 5; 5 4 3 2 1]) % 10 and 10
fitness([1]) % 0
fitness([2 4 1 3]) % 0 