function [p,V] = kuipertest2c(x1,x2)


x1 = sort(x1);
x2 = sort(x2);
n1 = length(x1(~isnan(x1)));
n2 = length(x2(~isnan(x2)));

binEdges    =  [-inf ; sort([x1;x2]) ; inf];

binCounts1  =  histc (x1 , binEdges, 1);
binCounts2  =  histc (x2 , binEdges, 1);

sumCounts1  =  cumsum(binCounts1)./sum(binCounts1);
sumCounts2  =  cumsum(binCounts2)./sum(binCounts2);

sampleCDF1  =  sumCounts1(1:end-1);
sampleCDF2  =  sumCounts2(1:end-1);

deltaCDF1  =  sampleCDF2 - sampleCDF1;
maxdeltaCDF1 = max(deltaCDF1);


deltaCDF2  =  sampleCDF1 - sampleCDF2;
maxdeltaCDF2 = max(deltaCDF2);

V = maxdeltaCDF1 + maxdeltaCDF2;

ne = ((n1*n2)/(n1+n2));
lambda  =  max((sqrt(ne) + 0.155 + (0.24/sqrt(ne))) * V);

if lambda<0.4  
p=1;  
h=0;
return
end

j=(1:100)';
pare=4*lambda*lambda*(j.^2)-1;
expo=exp(-2*lambda*lambda*(j.^2));
argo=pare.*expo;
p=2*sum(argo);

p = p;
V = V;