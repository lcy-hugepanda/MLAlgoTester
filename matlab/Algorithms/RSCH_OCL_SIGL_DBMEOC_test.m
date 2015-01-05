gridsize 120

a = MLAT_GenAritificialData(14);
%a = trainingA{1,1}{1}
load('E:\\ResearchCodes\\Data_BenchmarkForOCC\\MNIST\\MNIST_train_gist_10Classes.mat')
a = oc_set(x,1);

w= RSCH_OCL_SIGL_DBMEOC(a,0.05);
%w = OCLT_AlgoLibsvmOCSVM(target_class(a),'default',0.05,a);
% w = mog_dd(a,0.05);
%w = knndd(a,0.05);

scatterd(a);
res = a*w;
mcc = oc_mcc(a,w)
[e,f] = dd_error(a,w)
e_auc = dd_auc(dd_roc(a,w))

plotc(w)
V = axis;
hold on 

v = w.data;
for k =1 : 1 : v.k
    plotc(v.subW{k},'g')
    hold on
end

% 绘制MST
% style_style = {'r+','gx','b*','co'}; % 最多支持4个簇
% line_style   = {'r','g','b','c'}; % 最多支持4个簇
A_target = target_class(a);
v = w.data;
idx_core = v.Idx_core;
tree = v.mst;
dataM = A_target.data;

% core_set = v.core_set;
% for i = 1 : 1 : length(core_set)
%     hold on
%     scatter(dataM(core_set{i},1),dataM(core_set{i},2),'r+');
% end

scatter(dataM(idx_core,1),dataM(idx_core,2),'ro')
hold on
for j = 1 : 1 : size(tree,1)
  point =  dataM(tree(j,:),:);
  line(point(:,1), point(:,2),'Color','b');
end
axis(V)