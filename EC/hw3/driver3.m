% Ayat Ospanov & Eliot Heinrich
% This script plots
% number of evaluations vs dimension size
% for Sphere, Schwefel 1.2 and Rastrigins functions;
%
% The plots were made for the algorithms shown below

labels = ["CMA-ES (rank 1 and rank mu)", ...
    "CMA-ES (rank 1 update)", ...
    "CMA-ES (rank mu update)", ...
    "CMA-ES (no cov updates)", ...
    "DE (F = 0.85)", ...
    "DE (0.5 < F < 1.2)"];

linestyles = ["-+", "-o", "-*", "-s", "-x", "-d"];
sizes = 2:10;
S = length(sizes);
nevals = [1e7 1e7 2e5];
ranges_max = [100, 100, 5.12];

functions = {@sphere, @schwefel1p2, @rastriginsfcn};
problems = ["Sphere", "Schwefel 1.2", "Rastrigins"];

for f=1:length(functions)
    num_calls = zeros(length(labels), S);
    for n=1:S
        % CMA-ES
        for i=1:4
            [xmin,bestfitness,timesofar,bestsofar,callsofar] = ...
                purecmaes2(functions{f},sizes(n),nevals(f),...
                [-ranges_max(f) ranges_max(f)],i);
            
            num_calls(i, n) = callsofar(length(callsofar));
        end

        % DE
        for i=1:2
            [xmin,bestfitness,timesofar,bestsofar,callsofar] = ...
                deopt_rand_1_bin(functions{f},sizes(n),nevals(f),...
                [-ranges_max(f) ranges_max(f)],i);
            
            num_calls(4 + i, n) = callsofar(length(callsofar));
        end
    end
    
    figure;
    for i=1:6
        plot(sizes, num_calls(i, :), linestyles(i));
        hold on;
    end
    title(problems(f));
    ylabel('# of fitness evaluations');
    xlabel('dimension')
    legend(labels,'Location','Best');
end
