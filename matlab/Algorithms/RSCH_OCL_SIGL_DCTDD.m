% E10中用到的基算法
% 使用DBCV中的DCT树构建方法，利用DCT完成OCC任务
% 参数
%   A: 训练数据(纯数组，纯正类)
%   tree：DCT树，m x 3矩阵，每一行是一条边，[结点A 结点B 边长]
%   apts: 正类样本的core distance
%   compcl：聚类簇内最长可达距离
%   point_degree:聚类簇内样本点的degree
%   
%   
function out = RSCH_OCL_SIGL_DCTDD(varargin)
argin = setdefaults(varargin,[],0.05,[],[],0,[]);

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['DCT_DD_' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [A ,rejf, tree,apts, compcl, point_degree] = deal(argin{:});
    
    % 计算阈值
	int_node     = find(point_degree~=1);
    int_edg1     = find(ismember(tree(:,1),int_node));    
    int_edg2     = find(ismember(tree(:,2),int_node));    
    int_edges = intersect(int_edg1,int_edg2);
    thr = sort(tree(int_edges,3),'descend');
    thr = thr(fix(length(thr)*(1-rejf))+1);
%     thr = thr(fix(length(thr)*0.5));

    % 构建trained的prmapping
    data.tree = tree;
    data.apts = apts;
    data.compcl = compcl;
    data.A = A;
    data.thr = thr;
    data.point_degree = point_degree;
    
    dummy_label = ones(size(A,1),1);
    dummy_label(1) = 2;
    out = trained_classifier(prdataset(A, dummy_label), data);

% 测试部分
elseif mapping_task(argin,'execution')
    [A,v] = deal(argin{1:2}); 
	mapping = getdata(v);

    A_train = mapping.A;
    d = size(A,2);
    distM_core = pdist2(+A, A_train(find(mapping.point_degree > 3),:));
    distM = pdist2(+A, A_train);
    
    res = zeros(size(A,1),2);
    for i = 1 : 1 : size(A,1) % 对于每一个测试样本
        distV = sort(distM_core(i,:)); % 测试样本到所有target样本的距离（由小到大排序）
        
        core_dist = ((sum((1./distV).^d))./(size(A_train,1))).^(-1/d);
        core_dist = max([core_dist  min(distM_core(i,:))]);
%         res(i,1) = core_dist - mapping.compcl;
%         res(i,1) = mapping.compcl - core_dist;
        res(i,1) = core_dist - mapping.thr/2;
    end
    
    out = setdat(A,res,v); 
end
end