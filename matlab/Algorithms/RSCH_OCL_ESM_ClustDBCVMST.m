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
    [centers, Idx,k,tree,apts,dmreach,fdata,fcluster,fcompcl] = selectKbyDBCV(a, disM, nameClustAlgo,k);
    mstdata.center = centers;
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
    dist =  pdist2(a.data,mapping.mst.center,'Euclidean');
    [mmin,Idx] = min(dist,[],2);
    d_reach = cell(a.objsize);
    for i = 1:a.objsize
        dist = [];
        dist = pdist2(mapping.mst.fdata{Idx(i)},a.data(i,:),'Euclidean');
        numerator = sum((1./dist(find(dist ~= 0))) .^ a.featsize);
        %分子除ni-1后的-1/d次幂。
        apts(i) = (numerator/length(mapping.mst.fdata{Idx(i)})) ^(-1/a.featsize);
        %apts为测试集中每个点的apt值。mapping.mst.apts为训练集中点的apt值。
        for j = 1:length(mapping.mst.fdata{Idx(i)})
            d_reach{i}(j) = max([apts(i) mapping.mst.apts(mapping.mst.cluster{Idx(i)}(j)) dist(j)]);
        end
    end
    %d_reach为测试集中点到该聚类簇点的可达距离。

    % 设定每一个聚类簇的判定阈值
    thr = zeros(1,mapping.k);
    for i = 1 : 1 : mapping.k
%             mst_path = mapping.mst.path{i};
%             thr(i) = max(max(mst_path)) * (1 - 0.1);
%最长边thr
        mst_path = mapping.mst.tree{i}(:,3);
        thr(i) = max(mst_path) * (1 - 0.1);
%去掉1°点后thr
%        thr(i) = mapping.mst.compcl(i) * (1 - mapping.alf);
    end

    % 按照阈值判定测试点的归属
    result = zeros(a.objsize, 2);
    for i = 1 : 1 : a.objsize
        result(i,1) = min(d_reach{i}) - thr(Idx(i));
    end

    out = setdat(a,result,v);     
end
end
