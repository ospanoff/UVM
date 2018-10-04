% Ayat Ospanov & Eliot Heinrich
% This script plots
% boxplots of the distribution of Euclidean distances of the final
% best solutions to the global optimum over 50 runs
% for Sphere, Schwefel 1.2 and Rastrigins functions;
%
% The plots were made for the algorithms shown below in "labels"

sizes = [2 5 10];
jmax = 50;
maxevals = 1e5;
norms = zeros(jmax,6);
problems = {@sphere, @rastriginsfcn, @schwefel1p2};
probLabels = ["Sphere function", "Rastrigins function", "Schwefel 1.2 function"];
labels = ["CMA-ES (rank 1 and rank mu)", ...
   "CMA-ES (rank 1 update)", ...
   "CMA-ES (rank mu update)", ...
   "CMA-ES (no cov updates)", ...
   "DE (F = 0.85)", ...
   "DE (0.5 < F < 1.2)"];
ranges_max = [100 100 5.12];

% Do each problem
for k=1:length(problems)
    figure;
    % Loop through each N
    for n=1:length(sizes)
        % CMA-ES
        for i=1:4
            for j=1:jmax
                [xmin,bestfitness,timesofar,bestsofar,callsofar] = ...
                    purecmaes2(problems{k},sizes(n),maxevals,...
                    [-ranges_max(k) ranges_max(k)],i);
                norms(j,i) = norm(xmin);
%                 disp(j)
            end
        end
        % DE
        for i=5:6
            for j=1:jmax
                [xmin,bestfitness,timesofar,bestsofar,callsofar] = ...
                    deopt_rand_1_bin(problems{k},sizes(n),maxevals,...
                    [-ranges_max(k) ranges_max(k)],6-i);
                norms(j,i) = norm(xmin);
%                 disp(j)
            end
        end

        % boxplot for this problem and size
        subplot(length(sizes),1,n);
        if n == 3
            boxplot(norms,'Labels',labels');
        else
            boxplot(norms);
            set(gca,'xticklabel',[]);
        end
        title(probLabels(k) +  " (N = " + sizes(n) + ")");
        set(gca,'yscale','log');
        set(gca, 'fontsize', 13)
    end
end