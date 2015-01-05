% 这是一个备份文件，包含的是E12算法的一个早期版本
% 该版本可以接受各种聚类算法，然后用DBCV做K值选择
% 但是由于纯粹这样的话，创新性较差，因此暂时弃用

% E12论文的实验性算法
%
% 参数说明
% a: 训练数据集
% k: 聚类最大个数     
% numClustAlgo: 聚类算法名称
%       -- kmeans
%       -- enclust
%       -- hclust
%       -- modeseek
%       -- kcenters
%       -- fcm
%       -- dbscan
%alf:测试参数选择

function out = RSCH_OCL_ESM_ClustDBCVMST(varargin)
argin = setdefaults(varargin,[],3,'kcentres',0.1);
if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['MLAlgo_Ensemble_' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [a ,k,nameClustAlgo,alf] = deal(argin{:});
    % 单独提取正类样本用于训练
    a_origin = a;
    a = target_class(a);
    % 计算正类样本的距离矩阵（聚类算法需要）
    disM = sqrt(distm(a));
    % 确定聚类个数
    [core_point, core_point_idx,Idx,k,tree,apts,dmreach,fdata,fcluster,fcompcl] = ...
        selectKbyDBCV(a, disM, nameClustAlgo,k);
    
    fprintf('k = %d\n',k);
    
    mstdata.core_point = core_point;
    mstdata.core_point_idx = core_point_idx;
    mstdata.tree = tree;
    mstdata.apts = apts;
    mstdata.fdata = fdata;
    mstdata.dmreach = dmreach; 
    mstdata.Idx = Idx;
    mstdata.cluster = fcluster;
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
    Idx = mapping.mst.core_point_idx(min_idx);
    
    d_reach = cell(a.objsize);
    for i = 1:a.objsize
        dist = [];
%         dist = pdist2(mapping.mst.fdata{Idx(i)},a.data(i,:),'Euclidean');
        dist = pdist2(mapping.mst.core_point(find(mapping.mst.core_point_idx == Idx(i)),:),a.data(i,:),'Euclidean');
        numerator = sum((1./dist(find(dist ~= 0))) .^ a.featsize);
        %分子除ni-1后的-1/d次幂。
        apts(i) = (numerator/length(mapping.mst.fdata{Idx(i)})) ^(-1/a.featsize);
        %apts为测试集中每个点的apt值。mapping.mst.apts为训练集中点的apt值。
        for j = 1:1:length(mapping.mst.core_point(find(mapping.mst.core_point_idx == Idx(i)),:))
            d_reach{i}(j) = max([apts(i) mapping.mst.apts(mapping.mst.cluster{Idx(i)}(j)) dist(j)]);
%             d_reach{i}(j) = max([apts(i) mapping.mst.apts(mapping.mst.cluster{Idx(i)}(j))]);
%             d_reach{i}(j) = apts(i);
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
    
    %sm = sum(result,2);
    %result = result./repmat(sm,1,2);
    
    % 我是一个逗逼，但是我媳妇儿很美哦~
    % 单身狗木有人爱，我有媳妇儿，哈哈哈！
    % 我最爱媳妇儿了，你咬我！
    % 可惜我是个逗逼唉。。。真怕媳妇儿不要我了。。。呜呜呜呜。。。
    
    %result = 1 - result;
    out = setdat(a,result,v);     
end
end
