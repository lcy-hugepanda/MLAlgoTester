gridsize 50

a = MLAT_GenAritificialData(6);
w= RSCH_OCL_SIGL_DBMST(a,'dbscan',2,0.05);

testc(a,w);
scatterd(a);
plotc(w)
w2 = mst_dd(a,0.05);
testc(a,w2);
plotc(w2,'r');

A_target = target_class(a);
v = w.data;
Idx = v.Idx;
for i = 1 : 1 : v.k
   tree = v.mst{i};
   thisClusterIdx = find(Idx == i);
   thisClusterA = seldat(A_target, [],[], thisClusterIdx);
   dataM = thisClusterA.data;
   for j = 1 : 1 : size(tree,1)
      point =  dataM(tree(j,:),:);
      line(point(:,1), point(:,2));
   end
end