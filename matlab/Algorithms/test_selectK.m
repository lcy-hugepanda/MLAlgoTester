% a = gendatb([100 100]);
% a = oc_set(a,'1');
a = mydataset(1);
scatterd(a);
w = RSCH_OCL_ESM_ClustFramework(a,'entropy',10,'kcentres','gauss_dd','mergec');
