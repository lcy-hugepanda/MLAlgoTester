a = gendatb([100 100]);
a = oc_set(a,'1');
a = target_class(a);
% disM = sqrt(distm(a));
% [centers, Index,k] = selectKbyDBCV(a, disM, 'kcentres',8);

w = gauss_dd(a);
w2 = RSCH_OCL_ESM_ClustFramework(a,'DBCV',8,'kcentres','mst',maxc);
testc(a,w2);