% 一种实验方法
% 首先通过类似于DBCV的方式进行密度分析并得到各个聚类簇的最小生成树
% 之后对每一个MST进行分解并使用gauss_dd描述
% 最后使用mergec合并
% 参数
%   A: 训练数据
%   nameClustAlgo: 聚类算法名
%   k: 聚类算法的参数
%   frej: 拒绝率
function out = RSCH_OCL_SIGL_DBMST(varargin)
argin = setdefaults(varargin,[],0.1);

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['RSCH_DBCVMST' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [A ,frej] = deal(argin{:});
    % 单独提取正类样本用于训练
    A_target = target_class(A);
    num_target = size(A_target,1);
    
    % 聚类分析
%     switch nameClustAlgo
%         case 'dbscan'
%                 [Idx,type]=dbscan(+A_target,k,[]) ;
%                 num_clust = length(unique(Idx))-1; % -1 是outlier
%         case 'kmeans'
%                 Idx = kmeans(A_target,k);
%                 num_clust = length(unique(Idx));
%     end
            
    Idx = ones(size(A_target,1),1);
    [~,trees,adjM] = MLAT_DBCV(A_target,Idx);
    
    % 删除太长的边，比例以正类拒绝率frej决定 (当前，仅从adjM中删除)
    num_delete = fix(num_target * frej*2);
    pruned_adjM = adjM{1};
    while num_delete > 0
        [temp, del_x] = max(pruned_adjM);
        [temp, del_y] = max(temp);
        pruned_adjM(del_x(del_y),del_y) = 0;
        %fprintf('prun: %d %d\n',del_x(del_y),del_y);
        num_delete = num_delete - 1;
    end
    
    % 从树中分析得到core point
    % 同时以core point为核心构建每一个core set
    point_weight = zeros(1, num_target);
    idx_core = [];
    core_set = cell(0);
    for i = 1 : 1 : num_target  % 对于每一个点
        point_set = find(pruned_adjM(i,:)>0); % 获取与之相连的点集
        point_weight(i) = length(point_set);
        if point_weight(i) > 2   % 与之相连的点超过1个，就是core点
            idx_core = [idx_core; i];
            core_set = [core_set; point_set];   % 与core点相连的就是core集
        end
    end
   
    % 对每一个core集构建单类分类模型（这部分需要细化）
    subW = cell(1,length(core_set));
    for i = 1:1:length(core_set)
        A_target_thisCore = seldat(A_target,[],[],core_set{i});
        subW{i}= gauss_dd(A_target_thisCore,frej);
    end
    
    % 构建trained的prmapping
    data.Idx = Idx;
    data.Idx_core = idx_core;
    data.subW = subW;
    data.k = length(core_set);
    data.mst = trees;
    data.adjM = pruned_adjM;
    out = trained_classifier(A_target, data);
    
% 测试部分
elseif mapping_task(argin,'execution')
    [a,v] = deal(argin{1:2}); 
	mapping = getdata(v);
    w = mapping.subW;
    W_out = [w{:}] * mergec;
    out = a * W_out;
     
end
end