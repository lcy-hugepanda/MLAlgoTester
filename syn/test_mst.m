 a = mydataset(1);
%a = gendatb([100 100]);
a = oc_set(a,1);
w1 = mymst_dd(a);
w2 = mst_dd(a);
result(1,1) = testc(a,w1);
result(1,2) = testc(a,w2);
%  [E,F,G] = dd_error(a,w)
scatterd(a);
plotc(w1,'g');
plotc(w2,'r');