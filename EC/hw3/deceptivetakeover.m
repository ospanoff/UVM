function [gen]=deceptivetakeover(a,b,c,freq0,pc,pm,delta,L,maxgen)
% a 2-bit minimal deceptive problem (for any order-2 schema)
% with the following fitness structure for the 2 fixed bits: 
%            0 1
% fitness = [1 b; % 0
%            a c] % 1
% where:
%   1+b > a+c (i.e., f(0*)>f(1*)
%   a < b < c
%   a < 1
%   type 1 (easy): b > 1
%   type 2 (hard): b <= 1
% 
% freq0 is a 2x2 matrix of the initial relative frequencies of each genotype
% (note: the code turns these into probabilities that sum to 1.0)
% pc == probability of crossover
% pm == probability of mutation
% delta == defining length of schema (i.e., distance between these bits)
% L == length of chromosome (note L > delta)
% maxgen == maximum number of generations to simulate
%
% sample calls:
% deceptivetakeover(.5,1.01,1.1,[1 1;1 1],.8,0,1,2,100) %type 1: easy
% deceptivetakeover(.5,.9,1.1,[1 1;1 1],.8,0,1,2,100) %type 2: harder
% deceptivetakeover(.5,1.01,1.1,[3 3;3 1],.8,0,1,2,100) %type 1: easy
% deceptivetakeover(.5,.9,1.1,[3 3;3 1],.8,0,1,2,100) %type 2: harder
% 
% NOTE: neither of these problems is FULLY deceptive, since 
%   1+b > a+c; i.e., f(0*)>f(1*) so these BBs are deceptive BUT
%   1+a <= b+c; i.e., f(*0)<f(*1) so these BBs are not deceptive

if a >= b %without loss of generality
    temp=a;
    a=b;
    b=temp;
end

pcprime=pc*delta/(L-1); %take into account the defining length of the schema

% without loss of generality, assume that all fitnesses have been 
% normalized with respect to f00
f=[1 b;
   a c]

BBfitness=sum(f,2);
if BBfitness(1)<BBfitness(2)
    typemessage=('This problem is not deceptive');
elseif b > 1 
    typemessage='Type 1 deceptive:';
else
    typemessage='Type 2 deceptive';
end

P=zeros(2,2,maxgen+1);
P(1:2,1:2,1)=freq0/sum(freq0(:)); %turn freqs into probabilities

% compute simulated proportions of each schema in the population
for gen=1:maxgen
    P(:,:,gen+1)=nextPs(P(:,:,gen),f,pcprime,pm); %this function is below
    lastgen=P(:,:,gen+1);
    if any(abs(lastgen(:)-1)<1e-4) % does anybody have proportion of 1.0 (to within 1e-4)?
        break % exit if problem converges
    end
end

figure
linecolor=['cb';'gr'];
% plot the schema fitnesses
subplot(2,1,1)
for bit1=0:1
    for bit2=0:1
        plot3([bit1 bit1],[bit2 bit2],[0 f(bit1+1,bit2+1)],linecolor(bit1+1,bit2+1))
        hold on
    end
    plot3([0 1 1 0 0],[0 0 1 1 0],[f(1,1), f(2,1), f(2,2),f(1,2),f(1,1)],'k-')
end
plot3(1,1,f(2,2),'r*','markersize',10)
view(23,12)
grid on
axis square
set(gca,'xtick',[0 1],'ytick',[0 1],'xticklabel',[],'yticklabel',[],'zticklabel',[])
set(gca,'zlim',[0,max(f(:))])
text(-.1,-.1,'00'),
text(-.1,1.1,'01'),
text(1.1,-.1,'10'),
text(1.1,1.1,'11')
text(-.1,-.1,f(1,1)+.1,num2str(f(1,1)))
text(0,1,f(1,2)+.1,num2str(f(1,2)))
text(1,0,f(2,1)+.1,num2str(f(2,1)))
text(1,1,f(2,2)+.1,num2str(f(2,2)))
zlabel('relative fitness')

% plot the expected evolutionary change in proportions
subplot(2,1,2)
line_styles = ["-." ":"; "--" "-"];
for bit1=0:1
    for bit2=0:1
        tmp = strcat(linecolor(bit1+1,bit2+1), line_styles(bit1+1,bit2+1))
        plot(0:gen,squeeze(P(bit1+1,bit2+1,1:gen+1)),tmp);
        hold on
    end
end
legend('00','01','10','11')
xlabel('generation')
ylabel('proportion of population')
title([typemessage,', Pc=',num2str(pc),', Pm=',num2str(pm),', \delta=',num2str(delta),', L=',num2str(L)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P3=nextPs(P1,f,pcprime,pm) %function to compute all 4 schema probabilities for next gen
for bit1=0:1
    for bit2=0:1
        P2(bit1+1,bit2+1)=nextP(P1(:,:),f,bit1,bit2,pcprime); % calls the function below
    end
end
for bit1=0:1
    for bit2=0:1
        P3(bit1+1,bit2+1)=nextP_mut(P2(:,:),bit1,bit2,pm); % calls the function below
    end
end

% sumprob=sum(P2(:));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P=nextP(Pt,f,bit1,bit2,pcprime) % function to compute 1 schema prob for next gen
% Pt is 2x2 proportions at time t
% f is the 2x2 fitness function (indexed by bit)
% bit1 and bit2 are the two fixed bit values of the schema
% pcprime if the crossover probability, adjusted for defining length of the schema
% 
% ASSUMPTIONS:
% fitness proportionate selection, single point crossover, no mutation

% compute indeces from bit values by adding 1 
% (i.e., 0 and 1 bit values correspond to fitenss indeces 1 and 2)
i1=bit1+1; %index for first bit
i2=bit2+1; %index for second bit
c1=~bit1+1; %index for complement of first bit
c2=~bit2+1; %index for complement of second bit

fmean=sum(sum(Pt.*f)); % average fitness of current population

% difference approximation for estimating proportion P of this schema 
% at time t+1.
P=Pt(i1,i2)*f(i1,i2)/fmean*(1-pcprime*f(c1,c2)/fmean*Pt(c1,c2))...
    +pcprime*f(c1,i2)*f(i1,c2)/(fmean.^2)*Pt(c1,i2)*Pt(i1,c2);    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P=nextP_mut(Pt,bit1,bit2,pm) % function to compute 1 schema prob for next gen
% Pt is 2x2 proportions at time t
% bit1 and bit2 are the two fixed bit values of the schema
% pm if the mutation probability of a bit
% 
% ASSUMPTIONS:
% fitness proportionate selection, single point crossover, no mutation

% compute indeces from bit values by adding 1 
% (i.e., 0 and 1 bit values correspond to fitenss indeces 1 and 2)
i1=bit1+1; %index for first bit
i2=bit2+1; %index for second bit
c1=~bit1+1; %index for complement of first bit
c2=~bit2+1; %index for complement of second bit

% difference approximation for estimating proportion P of this schema 
% at time t+1 after mutation
P=(1 - pm)^2 * Pt(i1, i2)...
    + pm * (1 - pm) * (Pt(c1, i2) + Pt(i1, c2))...
    + pm^2 * Pt(c1, c2);
        