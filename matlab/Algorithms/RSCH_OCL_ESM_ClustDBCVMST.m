% E12算法
% 基于层次聚类、DBCV评价和DCT树的结构化集成OCC
%
% 参数说明
% a: 训练数据集
% k: 聚类最大个数     
%alf:测试参数选择

function out = RSCH_OCL_ESM_ClustDBCVMST(varargin)
argin = setdefaults(varargin,[],5,0.1);
if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['MLAlgo_Ensemble_' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [a ,k,alf] = deal(argin{:});
    
    % 单独提取正类样本用于训练
    a_origin = a;
    a = target_class(a);
    % 计算正类样本的距离矩阵（聚类算法需要）
    disM = pdist(+a);
    
    % 层次聚类
%   这里原来用的是PRTools的hclust函数，但是这个函数不支持最常用的ward，所以弃用
% 	dendg = hclust(disM,'average'); % dendrogram
% 	plotdg(dendg)
    % 使用ward得到层次聚类树，返回的clust是一个(m-1)x3的矩阵，m是样本的个数
    % 矩阵的每一行表示了一次聚合：聚合簇1，聚合簇2，聚合时距离
    clust = linkage(disM,'ward');  
    
    % 确定聚类个数
    [core_point, core_point_idx,Idx,k,tree,apts,dmreach,fdata,fclusterIdx,fcompcl] = ...
        E12_DBCV(a, clust,k);
    
    fprintf('k = %d\n',k);
    
    mstdata.core_point = core_point;
    mstdata.core_point_idx = core_point_idx;
    mstdata.tree = tree;
    mstdata.apts = apts;
    mstdata.fdata = fdata;
    mstdata.dmreach = dmreach; 
    mstdata.Idx = Idx;
    mstdata.clusterIdx = fclusterIdx;
    mstdata.compcl = fcompcl;
    % 构建trained的prmapping
    data.Idx = Idx;
    data.k = k;
    data.mst = mstdata;
    data.alf = alf;
    out = trained_classifier(a_origin, data);    
% 测试部分
elseif mapping_task(argin,'execution')
    [a,v] = deal(argin{1:2}); 
    a = prdataset(a);
	mapping = getdata(v);   
    
    % 确定每一个测试样本所属的聚类簇
    % 原来的逻辑是计算样本和各个聚类中心点的距离
%     dist =  pdist2(a.data,mapping.mst.center,'Euclidean');
%     [mmin,Idx] = min(dist,[],2);
    % 现在需要改成与core点之间的距离
    dist = pdist2(a.data,mapping.mst.core_point,'Euclidean');
    [~,min_idx] = min(dist,[],2);
    Idx = mapping.mst.core_point_idx(min_idx); % Idx表示测试集中各个点所属的聚类簇
    
    d_reach = cell(a.objsize);
    for i = 1:a.objsize
%         dist = pdist2(a.data(mapping.mst.clusterIdx{Idx(i)},:),a.data(i,:),'Euclidean');
%         numerator = sum((1./dist(find(dist>0))) .^ a.featsize);
%         %分子除ni-1后的-1/d次幂。
%         apts(i) = (numerator/length(mapping.mst.clusterIdx{Idx(i)})) ^(-1/a.featsize);
%         %apts为测试集中每个点的apt值。mapping.mst.apts为训练集中点的apt值。
%         for j = 1:1:length(mapping.mst.clusterIdx{Idx(i)})
% %             d_reach{i}(j) = min([apts(i) mapping.mst.apts(mapping.mst.clusterIdx{Idx(i)}(j)) dist(j)]);
%             d_reach{i}(j) = max([apts(i) min(dist)]);
%         end        
        
        % 仅使用各聚类簇的core点计算可达距离
        data_core = [mapping.mst.core_point(find(mapping.mst.core_point_idx == Idx(i)),:); a.data(i,:)];
        dist_core = pdist(data_core,'Euclidean');
        for i = 1 : 1 : size(data_core,1)
            numerator = sum((1./dist_core(find(dist_core > 0))) .^ a.featsize);
            %分子除ni-1后的-1/d次幂。
            apts(i) = (numerator/length(find(mapping.mst.core_point_idx == Idx(i)))) ^(-1/a.featsize);
        end

        %apts为测试集中每个点的apt值。mapping.mst.apts为训练集中点的apt值。
        for j = 1:1:length(find(mapping.mst.core_point_idx == Idx(i)))
%             d_reach{i}(j) = max([apts(i) mapping.mst.apts(mapping.mst.clusterIdx{Idx(i)}(j)) dist(j)]);
            d_reach{i}(j) = max([apts(i) min(mapping.mst.apts(find(mapping.mst.clusterIdx==i)))  min(dist_core(j))]);
        end
    end
    %d_reach为测试集中点到该聚类簇点的可达距离。

    % 设定每一个聚类簇的判定阈值
    thr = zeros(1,mapping.k);
    for i = 1 : 1 : mapping.k
%             mst_path = mapping.mst.path{i};
%             thr(i) = max(max(mst_path)) * (1 - 0.1);
%按照阈值去除过长边的最长边thr
        mst_path = sort(mapping.mst.tree{i}(:,3));
        thr_2 = max(mst_path(1:fix(length(mst_path)*(1-mapping.alf))));
%最长边thr
        mst_path = mapping.mst.tree{i}(:,3);
        thr_3 = max(mst_path);
%平均边长thr
        mst_path = mapping.mst.tree{i}(:,3);
        thr_4 = mean(mst_path);
%去掉1°点后thr
        thr_5 = mapping.mst.compcl(i) * (1 - mapping.alf);

        thr(i) = thr_3;
    end

    % 按照阈值判定测试点的归属
    result = zeros(a.objsize, 2);
    for i = 1 : 1 : a.objsize % 对于每一个样本
        result(i,1) = min(d_reach{i}) - thr(Idx(i));
    end

    out = setdat(a,result,v);     
end
end


function [core_point, core_point_idx, Index,k,tree,fapts,freach,fdata,fclusterIdx,fcompcl] = E12_DBCV(a, clust,k)
    is_found_k = 0;
    for i = 2:k 
        Idx{i} = cluster(clust,'maxclust',i);
        [dbcv(i),ftree{i},apts{i},dmreach{i},data{i},clusterIdx{i},compcl{i},point_degree{i}]...
            = DBCV(a.data,Idx{i},'normal');
    end
    if ~is_found_k
        [~,i] = max(dbcv(2:end));
        best_k = i + 1;
    end
    
    % 这里原来的逻辑是存储k-centers的聚类中心，但是这样就限制了聚类算法，不太合适
%     for j = 1:i
%         centers(j,:) = a.data(center{i}(j),:);
%     end
    % 新的逻辑，以每一个聚类簇中core点为线索，确定后续样本所属的聚类簇
    dataM = getdata(a);
    core_point = []; % 每一行两个元素，第一个是聚类簇标号，第二个是聚类簇中该样本的标号
    core_point_idx = [];
    degree = point_degree{best_k};
    for i = 1 : 1 : best_k % 对于每一个聚类簇
        idx_this_clusterIdx = clusterIdx{best_k}{i}; % 该聚类簇中样本的标号  
        for j = 1 : 1 : length(idx_this_clusterIdx)  % 对于聚类簇中每一个点
            if degree{i}(j) > 2   % 与之相连的点超过3个，就是core点                     
                core_point  = [core_point;data{best_k}{i}(j,:)];
                core_point_idx = [core_point_idx; i];
            end
        end
    end
        
    Index = Idx{best_k};
    k = best_k;
    tree = ftree{best_k};
    fdata = data{best_k};
    fapts = apts{best_k};
    freach = dmreach{best_k};
    fclusterIdx = clusterIdx{best_k};
    fcompcl = compcl{best_k};
end