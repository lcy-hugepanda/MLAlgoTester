% 一种实验方法 E-10
% 首先通过类似于DBCV的方式进行密度分析并得到各个聚类簇的最小生成树
% 之后对每一个MST进行分解并使用gauss_dd描述
% 最后使用mergec合并
% 参数
%   A: 训练数据
%   nameClustAlgo: 聚类算法名
%   k: 聚类算法的参数
%   frej: 拒绝率
function out = RSCH_OCL_SIGL_DBMEOC(varargin)
argin = setdefaults(varargin,[],0.1,0.01,false,0.1);

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['RSCH_E10_DBM-EOC' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [A ,frej,delete_thr,is_merge_core, para_gauss] = deal(argin{:});
    % 这里有一些微调选项
    knn_para = 1; % 越大的话，参与KNN的点越少，取1的时候和所有点取KNN
    is_delete_edge = true; % 是否根据DCT树的长度分布删除过于长的边
%     delete_para = 5; % 越大的话删除的边越少，默认取5
%     delete_thr = 0.015; % Z检验删除长边的置信区间
%     is_merge_core = false; % 是否将过于小的core集合并到大的core集中
%     para_gauss = 0.1;
    
    % 单独提取正类样本用于训练
    A_target = target_class(A);
    [num_target,d] = size(A_target);

    % 密度分析
    index = ones(size(A_target,1),1);
    dataM = +A_target;
    
    % 计算每一个样本的APT
    o = 1;
    %得到距离矩阵
    distM =  squareform( pdist(dataM, 'euclidean'));  
    for j = 1:num_target
        %分子，求除点j外，点j到其他所有点距离倒数d次幂,最后求和
        this_point_dist = sort(distM(j,:));
        knn_point_dist = this_point_dist(2:fix(length(this_point_dist)/knn_para));
        numerator = sum((1./knn_point_dist).^ 2);
        %分子除ni-1后的-1/d次幂。
        apts(o) =  (numerator/ (num_target - 1)) ^(-1/ 2) ;
        o = o + 1;
    end
     
    %计算可达距离
    for i = 1:1:num_target
        for j = 1:1:num_target
            d_mreach(i,j) = max([ min([apts(i) apts(j)]) distM(i,j)]); 
%             d_mreach(i,j) = max([apts(i) apts(j) distM(i,j)]);
%             d_mreach(i,j) = max([apts(i) apts(j)]);
%             d_mreach(i,j) = distM(i,j);
        end
    end
    %conducting an MST
    [trees,adjM]=mst(d_mreach);
    
    % 删除太长的边 (当前，仅从adjM中删除)
    % 实验显示在某些数据集上，完全不删除的效果可能更好一点
    % 因此这里的处理需要更谨慎一些，考虑参照MST_CD的方式
    pruned_adjM = adjM;
    length_edge = pruned_adjM(find(pruned_adjM>0));
    
    % Z-test的pruning逻辑
    outlier = [];
    for i = 1 : 1 : length(length_edge)
        z = ztest(length_edge(i),mean(length_edge),std(length_edge),delete_thr);
        if 1 == z
            outlier = [outlier length_edge(i)];
        end
    end

%     这里注释掉的是一种简单粗暴的pruning，这部分只需要得出一个数量即可
%     length_edge = sort(length_edge);
%     k1 = 1;
%     k2 = 1;
%     inlier = [];
%     outlier = [];
%     len = length(length_edge);
%     average1 = mean(length_edge);
%     standard1 = std(length_edge);
%     for i = 1:len
%         if abs( length_edge(i) - average1) < k1 * standard1
%             inlier = [inlier length_edge(i)];
%         end
%     end
%     average2 = mean(inlier);
%     standard2 = std(inlier);
%     for i = 1:len
%         if length_edge(i) - average2 >= k2 * standard2 * delete_para %这里不取绝对值，因为我们只关心太长的边
%             outlier = [outlier length_edge(i)];
%         end
%     end
    
    num_delete = length(outlier);
    fprintf('%d egdes deleted . \n',num_delete);
    
    % 这是之前的逻辑，按照从大到小的顺序删除若干条边，数量决定于frej
    %num_delete = fix(num_target * frej * 2);
    if ~is_delete_edge
        num_delete = 0;
    end
    pruned_adjM = adjM;
    pruned_trees = trees;
    deleted_edges = [];
    while num_delete > 0
        [temp, del_x] = max(pruned_adjM);
        [temp, del_y] = max(temp);
        pruned_adjM(del_x(del_y),del_y) = 0;
        
         fprintf('prun: %d %d\n',del_x(del_y),del_y);
        % 这部分用于MNIST找出outlier图片
%         fprintf('prun: %f %f\n',dataM(del_x(del_y),1),dataM(del_x(del_y),2));
%         fprintf('prun: %f %f\n',dataM(del_y,1),dataM(del_y,2));

        num_delete = num_delete - 1;
        
        
        % 同时需要得出一个pruned之后的tree
        for i = 1 : 1 : size(pruned_trees,1)
            if pruned_trees(i,1) == del_x(del_y) && pruned_trees(i,2) == del_y
                pruned_trees(i,:) = [0 0];
                deleted_edges = [deleted_edges ;trees(i,:)];
            end
        end
    end
    
    % 从树中分析得到core point
    % 同时以core point为核心构建每一个core set
    point_weight = zeros(1, num_target);
    idx_core = [];
    core_set = cell(0);
    for i = 1 : 1 : num_target  % 对于每一个点
        point_set = find(pruned_adjM(i,:)>0); % 获取与之相连的点集
        point_weight(i) = length(point_set);
        if point_weight(i) > 1   % 与之相连的点超过1个，就是core点
            % 实验性，如果core集点太少，对两边的点做扩展
%             if point_weight(i) < 5
%                 for j = 1 : 1 : point_weight(i)
%                     addon_point_set = intersect(...
%                         find(pruned_adjM(point_set(j),:)>0),...
%                         find(pruned_adjM(point_set(j),:)<50*pruned_adjM(i,point_set(j))));
%                     addon_point_set(find(addon_point_set == i)) = [];
%                     point_set = [point_set addon_point_set];
%                 end
%             end                      
            idx_core = [idx_core; i];
            core_set = [core_set; point_set];   % 与core点相连的就是core集
        end
    end
    
    if is_merge_core
        % 实验性，如果core点相连，合并core集
        for i = 1 : 1 : length(idx_core) % 针对每一个core点，尝试看是不是还属于其他core集
            appeared_core_set = [];
            for j = 1 : 1 : length(core_set) % 寻找core点所在的core集
                appeared_core_set = [appeared_core_set j];
            end
            if length(appeared_core_set)>1
                new_core_set = [];
                for j = 1 : 1 : length(appeared_core_set) % 连接这些core_set
                    if length(core_set{appeared_core_set(j)}) < 4
                        new_core_set = [new_core_set core_set{appeared_core_set(j)}];
                        core_set{appeared_core_set(j)} = [];
                    end
                end
                core_set{appeared_core_set(1)} = unique(new_core_set);
            end
        end
    end
    
    % 对每一个core集构建单类分类模型（这部分需要细化）
%     subW = cell(1,length(core_set));  
    subW = cell(0);
    w_idx = 1;
    for i = 1:1:length(core_set)
        if isempty(core_set{i})
            continue;
        end
        A_target_thisCore = seldat(A_target,[],[],core_set{i});
        if 2 == size(A_target_thisCore,1)
            dataM = +A_target_thisCore;
            if 0 == sum(dataM(1,:)-dataM(2,:))
                continue;
            end
        end
        if 3 == size(A_target_thisCore,1)
            dataM = +A_target_thisCore;
            if 0 == sum(dataM(1,:)-dataM(2,:))
                if 0 == sum(dataM(2,:)-dataM(3,:))
                    continue;
                end
            end
        end
        if size(A_target_thisCore,1) > 1
            subW{w_idx}= gauss_dd(A_target_thisCore,frej,para_gauss);
%             subW{w_idx}= parzen_dd(A_target_thisCore,frej);
%             subW{w_idx}=OCLT_AlgoLibsvmOCSVM(A_target_thisCore, 'default', frej, A_target_thisCore);
            % subW{w_idx}=incsvdd(A_target_thisCore, frej,1.0/d);
            w_idx = w_idx +1 ;
        end
    end
    
    % 构建trained的prmapping
    data.Idx_core = idx_core;
    data.subW = subW;
    data.k = length(subW);
    data.mst = trees;
    data.mst_pruned = pruned_trees;
    data.deleted_edges = deleted_edges;
    data.adjM = pruned_adjM;
    data.core_set = core_set;
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