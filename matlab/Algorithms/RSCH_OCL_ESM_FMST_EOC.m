% 参数说明
% a: 训练数据集
% OCCAlgo: 基单类分类器表达式，请使用直接调用的格式
% combineRule: 基分类器的集成方法
%       -- mergec 最大化决策边界集成
function out = RSCH_OCL_ESM_FMST_EOC(varargin)
argin = setdefaults(varargin,[],'gauss_dd',mergec);
if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['FMST' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [a,OCCAlgo,combineRule] = deal(argin{:}); 
    data.combinRule = combineRule;
    % 单独提取正类样本用于训练
     a_origin = a;
     a = target_class(a);
    % 第一次聚类
     n = length(a.data);
     
     % 这里根据基分类器的计算复杂度设定k
      k = floor(sqrt(n));
     %k = size(a,2); % 以维数d为k，用于Guass
     
     
    %DAC Divide and Conquer Using K-means
    [Idx, C] = kmeans(a.data, k, 'Replicates',1,'emptyaction','drop');
    
    % 删除包含点过少的聚类簇
    k_valid = k;
    for i = 1 : 1 : k
        if length(find(Idx == i)) < 3
            Idx(Idx == i) = [];
            k_valid = k_valid - 1;
        end
    end
    
     % 对每一个聚类簇生成单类分类模型
    subW1 = cell(1,k_valid);
    for i = 1:1:k_valid
        thisClusterIdx = find(Idx==i);
        A = seldat(a, [],[], thisClusterIdx);
        subW1{i}= eval(OCCAlgo);
    end
    data.subW1 = subW1;
    %第二次聚类  
    dist_c = squareform( pdist(C, 'euclidean'));  
   [tree_c,]=mst(dist_c);
    for i = 1:length(tree_c)
       cluster(i,:) = (C(tree_c(i,1),:)+ C(tree_c(i,2),:))/2;
    end
   [IDX2, C2] = kmeans(a.data, k-1,'Start',cluster, 'Replicates',1,'emptyaction','drop','MaxIter',1);
    
   % 删除包含点过少的聚类簇
    k_valid = k-1;
    for i = 1 : 1 : k-1
        if length(find(IDX2 == i)) < 3
            IDX2(IDX2 == i) = [];
            k_valid = k_valid - 1;
        end
    end
   
    subW2 = cell(1,k_valid);
    for i = 1:1:k_valid
        thisClusterIdx = find(IDX2==i);
        A = seldat(a, [],[], thisClusterIdx);
        subW2{i}= eval(OCCAlgo);
    end
    data.subW2 = subW2;
    % 构建trained的prmapping
    out = trained_classifier(a_origin, data);    
% 测试部分
elseif mapping_task(argin,'execution')
    [a,v] = deal(argin{1:2}); 
    a = prdataset(a);
	mapping = getdata(v);   
%     w = [mapping.subW1,mapping.subW2];
    combineRule = mapping.combinRule;
    w1 = mapping.subW1;
    w2 = mapping.subW1;
    W_out = [w1{:} w2{:}] * combineRule;
    out = a * W_out; 
end
end