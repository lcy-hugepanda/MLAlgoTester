a = gendatb([50 50]);
a = oc_set(a,'1');
w = mymst_dd(a);
% a = MLAT_GenAritificialData(1);
% w= RSCH_OCL_ESM_ClustDBCVMST(a,'kmeans',4,0.05);

testc(a,w);
scatterd(a);
plotc(w)
w2 = mst_dd(a,0.05);
testc(a,w2);
plotc(w2,'r');

a_target = target_class(a);
a_data = a_target.data;
v = w.data;
for i = 1 : v.k
   tree = v.mst{i};
   for j = 1 : size(tree,1)
      point =  a_data(tree(j,:),:);
      line(point(:,1), point(:,2));
   end
end