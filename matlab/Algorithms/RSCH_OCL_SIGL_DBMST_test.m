gridsize 100

a = MLAT_GenAritificialData(6);
w= RSCH_OCL_SIGL_DBMST(a,0.1);

testc(a,w);
scatterd(a,'w.');
plotc(w)
V = axis;
hold on

% 绘制MST
% style_style = {'r+','gx','b*','co'}; % 最多支持4个簇
% line_style   = {'r','g','b','c'}; % 最多支持4个簇
A_target = target_class(a);
v = w.data;
idx_core = v.Idx_core;
tree = v.mst{1};
dataM = A_target.data;
scatter(dataM(:,1),dataM(:,2),'b+'); 
scatter(dataM(idx_core,1),dataM(idx_core,2),'ro')
hold on
for j = 1 : 1 : size(tree,1)
  point =  dataM(tree(j,:),:);
  line(point(:,1), point(:,2),'Color','b');
end
axis(V)