% Ayat Ospanov & Eliot Heinrich
% This script plots
% Best fitness vs. Runtimes and
% Best fitness vs. Number of evals
% for Sphere, Schwefel 1.2 and Rastrigins functions;
%
% The plots were made for the algorithms shown below

labels = ["CMA-ES (rank 1 and rank mu)", ...
    "CMA-ES (rank 1 update)", ...
    "CMA-ES (rank mu update)", ...
    "CMA-ES (no cov updates)", ...
    "DE (F = 0.85)", ...
    "DE (0.5 < F < 1.2)"];

linestyles = ["+", "o", "*", "s", "x", "d"];
steps = [60 70 10];
sizes = [2 5 10];
S = length(sizes);
nevals = [1e7 1e7 1e5];
ranges_max = [100, 100, 5.12];

functions = {@sphere, @schwefel1p2, @rastriginsfcn};
problems = ["Sphere", "Schwefel 1.2", "Rastrigins"];
for f=1:length(functions)
    figure;
    for n=1:S
        % CMA-ES
        for i=1:4
            [xmin,bestfitness,timesofar,bestsofar,callsofar] = ...
                purecmaes2(functions{f},sizes(n),nevals(f),...
                [-ranges_max(f) ranges_max(f)],i);
            k = length(timesofar);

            subplottight(S,2,2*n-1);
            semilogy(timesofar(1:steps(f):k),bestsofar(1:steps(f):k),linestyles(i));
            set(gca, 'fontsize', 13)
            hold on;

            subplottight(S,2,2*n);
            semilogy(callsofar(1:steps(f):k),bestsofar(1:steps(f):k),linestyles(i));
            set(gca, 'fontsize', 13)
            hold on;
        end

        % DE
        for i=1:2
            [xmin,bestfitness,timesofar,bestsofar,callsofar] = ...
                deopt_rand_1_bin(functions{f},sizes(n),nevals(f),...
                [-ranges_max(f) ranges_max(f)],i);
            k = length(timesofar);

            subplottight(S,2,2*n-1);
            semilogy(timesofar(1:steps(f):k),bestsofar(1:steps(f):k),linestyles(4+i));
            hold on;

            subplottight(S,2,2*n);
            semilogy(callsofar(1:steps(f):k),bestsofar(1:steps(f):k),linestyles(4+i));
            hold on;
        end

        legend(labels,'Location','Best');
        subplottight(S,2,2*n - 1);
        title(problems(f) + " function (N=" + sizes(n) + ")");

        subplottight(S,2,2*n);
        title(problems(f) + " function (N=" + sizes(n) + ")");
    end

    subplottight(S,2,2*S);
    xlabel("Number of calls");
    subplottight(S,2,2*S-1);
    xlabel("Runtimes");
    subplottight(S,2,3);
    ylabel("Best fitness");
    drawnow;
end

function h = subplottight(n,m,i)
    [c,r] = ind2sub([m n], i);
    w = 1/m;
    h = 1/n;
    xfrac = 0.8;
    yfrac = 0.7;
    xdif = w * (1 - xfrac) / 2;
    ydif = h * (1 - xfrac);
    yPos = 1-(r)/n + ydif;
    if c == 1
        xPos = (c-1)/m + xdif;
    else
        xPos = (c-1)/m;
    end
    ax = subplot('Position', [xPos, yPos, xfrac * w, yfrac * h]);
    if(nargout > 0)
      h = ax;
    end
end