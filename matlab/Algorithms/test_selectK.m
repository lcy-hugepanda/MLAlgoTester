% a = gendatb([100 100]);
% a = oc_set(a,'1');
a = mydataset(1);

w1 = RSCH_OCL_ESM_ClustFramework(a,'direct',3,'kcentres','gauss_dd',maxc);
w2 = RSCH_OCL_ESM_ClustDBCVMST(a,10,'kcentres',0.1);
scatterd(a);
plotc(w2,'b');
plotc(w1,'g');