% Ayat Ospanov & Eliot Heinrich
% This script plots
% Runtime vs dimension size
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
sizes = 5:30;
S = length(sizes);
nevals = [1e4 1e4 1e4];
ranges_max = [100, 100, 5.12];

functions = {@sphere, @schwefel1p2, @rastriginsfcn};
problems = ["Sphere", "Schwefel 1.2", "Rastrigins"];

for f=1:length(functions)
    disp(problems(f))
    num_calls = zeros(length(labels), S);
    for n=1:S
        disp(n)
        % CMA-ES
        for i=1:4
            [xmin,bestfitness,timesofar,bestsofar,callsofar] = ...
                purecmaes2(functions{f},sizes(n),nevals(f),...
                [-ranges_max(f) ranges_max(f)],i);
            
            num_calls(i, n) = timesofar(length(timesofar));
        end

        % DE
        for i=1:2
            [xmin,bestfitness,timesofar,bestsofar,callsofar] = ...
                deopt_rand_1_bin(functions{f},sizes(n),nevals(f),...
                [-ranges_max(f) ranges_max(f)],i);
            
            num_calls(4 + i, n) = timesofar(length(timesofar));
        end
    end
    
    figure;
    for i=1:6
        plot(sizes, num_calls(i, :), linestyles(i));
        hold on;
    end
    title(problems(f));
    ylabel('Runtime');
    xlabel('Dimension')
    legend(labels,'Location','Best');
end
