% a = mydataset(1);
% a = oc_set(a,1);
% prload('auto_mpg_above25.mat');
% a = x;
a  = MLAT_GenAritificialData(6);
indexs(1,1:200) = 1;
indexs(1,201:320) = 2;
k = 8;
for i=2:k
    w{i} = ensemble_classification(a,i,'kmeans','parzen_dd',maxc);
    %w{i} = ensemble_classification(a,i,'kmeans','gauss_dd',maxc);
    index{i} =  w{i}.data.Idx;
    result(i,1) = feval('MLAT_ARI',indexs',index{i});    
    %result(i,2) =  dd_auc(dd_roc(a,w{i}));
    result(i,2) =  dd_f1(a,w{i});
end
scatterd(a);
plotc(w{3});
% index4 = kmeans(a,4);
% index3 = kmeans(a,3);
% indexk = emclust(a,[],4,[]);
% result(1,1) = MLAT_ARI(index',index3);
% result(2,1) = MLAT_ARI(index',index3);
% w1 = ensemble_classification(a,3,'kmeans','gauss_dd',maxc);
% result(1,2) = dd_f1(a,w1);
% w2 = ensemble_classification(a,4,'kmeans','gauss_dd',maxc);
% result(2,2) = dd_f1(a,w2);