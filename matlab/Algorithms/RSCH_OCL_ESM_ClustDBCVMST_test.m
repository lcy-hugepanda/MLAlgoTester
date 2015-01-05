gridsize 50

a = MLAT_GenAritificialData(14);
w= RSCH_OCL_ESM_ClustDBCVMST(a,10,0.05);

res_d = labeld(a,w);
res = struct(a*w);
[e, f] = testc(a,w)
scatterd(a);
plotc(w)

% w2 = mst_dd(a,0.05);
% testc(a,w2);
% plotc(w2,'r');

% ªÊ÷∆DCT
A_target = target_class(a);
v = w.data;
Idx = v.Idx;
for i = 1 : 1 : v.k
   tree = v.mst.tree{i};
   thisClusterIdx = find(Idx == i);
   thisClusterA = seldat(A_target, [],[], thisClusterIdx);
   dataM = thisClusterA.data;
   for j = 1 : 1 : size(tree,1)
      point =  dataM(tree(j,1:2),1:2);
      line(point(:,1), point(:,2));
   end
end