

%A = gendatb([50, 150]);
%A = setprior(A,[]);
scatterd(A);
W = MLAlgo_LOCI(A,0.5,10);
[E, C] = testc(A, W)