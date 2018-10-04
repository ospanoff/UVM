function f=schwefel1p2(x)
f=zeros(size(x,1),1); % assumes rows are individuals
for guy=1:size(x,1)
    for i=1:size(x,2) %each column holds an allele
        f(guy)=f(guy)+sum(x(guy,1:i)).^2;
    end
end