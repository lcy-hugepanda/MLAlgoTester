% 用于测试DCT_DD算法
% 由于DCT_DD是用于E12的基分类器，所以这里测试的时候也是按照E12的方法传入参数

% 就用BrokenBanana就好，俩cluster很明显
a_orig = MLAT_GenAritificialData(14);
a = target_class(a_orig);

k = 2;
disM = pdist(+a); % 距离矩阵
clust = linkage(disM,'ward');  % 层次聚类结果
Idx = cluster(clust,'maxclust',k);  % 聚类结果
[dbcv,ftree,apts,dmreach,data,clusterIdx,compcl,point_degree] = DBCV(+a,Idx,'normal');
    % dbcv: 该聚类结果的DBCV评估值（这个测试中并不需要）
    % ftree：k棵DCT树的边(1xk的cell数组)，每一条边的表示方式是[结点A 结点B 边长]
    % apts：DBCV计算时用到的core distance
    % dmreach：k棵DCT树的可达距离矩阵（1xk的cell数组），矩阵是对称阵
    % data：k棵DCT树的原数据(1xk的cell数组)，和输入的+a格式一样
    % clusterIdx：k棵DCT树中(1xk的cell数组)，每一颗中元素在原a中的序号
    % compcl：各聚类簇内的密度最小度量值（聚类簇内可达距离最大值）
    % point_degree：k棵DCT树中(1xk的cell数组)，每一个点的degree
    
% 以下对于每一个聚类簇生成对应的DCT_DD
w = cell(1,k); % 基分类器
for i = 1 : 1 : k
    w{i} = RSCH_OCL_SIGL_DCTDD(data{i},0.1,ftree{i},apts(clusterIdx{i}),compcl(i),point_degree{i});
end

% 可视化
scatterd(a_orig);
hold on
for i = 1 : 1 : k
    plotc(w{i});
    hold on
end

