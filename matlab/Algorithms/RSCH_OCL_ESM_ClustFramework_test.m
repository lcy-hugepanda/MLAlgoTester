gridsize 50

a = MLAT_GenAritificialData(8);
w = RSCH_OCL_ESM_ClustFramework(a,'DBCV',8,'kcentres','mst','NA');

scatterd(a);
res = a*w;
mcc = oc_mcc(a,w)
[e,f] = dd_error(a,w)
e_auc = dd_auc(dd_roc(a,w))

plotc(w)
V = axis;
hold on 