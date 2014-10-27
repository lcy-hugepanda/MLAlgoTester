% 参数说明
% a: 训练数据集
% numClust: 如何确定聚类个数
%       --'direct'   即直接给出聚类个数
%       --'entropy' 利用熵确定聚类个数
% k: 补充参数
%       -- 如果numClust是'direct'，则k给出具体的聚类个数
%       -- 如果numClust是其他自动确定聚类个数的方法，则k给出聚类个数上限
%       -- 如果聚类算法不需要指定聚类个数，则k是该聚类算法的必须参数（例如DBSCAN）
% numClustAlgo: 聚类算法名称
%       -- kmeans
%       -- enclust
%       -- hclust
%       -- modeseek
%       -- kcenters
%       -- fcm
%       -- dbscan
% OCCAlgo: 基单类分类器表达式，请使用直接调用的格式
% combineRule: 基分类器的集成方法
%       -- maxc 最大化决策边界集成

function out = RSCH_OCL_ESM_ClustFramework(varargin)
argin = setdefaults(varargin,[],3,'kmeans','svdd',maxc);
if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['MLAlgo_Ensemble_' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [a ,numClust,k ,nameClustAlgo,OCCAlgo,combineRule] = deal(argin{:});
    % 单独提取正类样本用于训练
    a = target_class(a);
    % 计算正类样本的距离矩阵（聚类算法需要）
    disM = sqrt(distm(a));
        
    % 确定聚类个数
    if strcmp(numClust,'direct')
        ; % 直接使用参数k
    end
    
    % 调用聚类算法,聚类个数输入是k，其他参数全部设置默认值或替换到位
    switch nameClustAlgo
        case 'kmeans'
            Idx = feval(nameClustAlgo,a,k);
        case 'emclust'
            Idx = feval(nameClustAlgo,a,[],k,[]);
        case 'hclust'            
            Idx = feval(nameClustAlgo,disM,'complete',k);
        case 'modeseek'
            Idx = feval(nameClustAlgo,disM,k);
        case 'kcentres'
            Idx = feval(nameClustAlgo,disM,k);
        case 'fcm'
            [center,U,obj_fcn] = fcm(a.data,k);
            maxU = max(U);
            Idx = zeros(length(a.data),1);
            for i = 1:k  
                Idx(find(U(i,:) == maxU)) = i;
            end 
        case 'dbscan'
            [Idx,type]=dbscan(a.data,k,[]) ;
            k = max(unique(Idx));
    end
    
    
    % 对每一个聚类簇生成单类分类模型
    subW = cell(1,k);
    for i = 1:1:k
        thisClusterIdx = find(Idx==i);
        A = seldat(a, [],[], thisClusterIdx);
        subW{i}= eval(OCCAlgo);
    end
    
    % 构建trained的prmapping
    data.Idx = Idx;
    data.subW = subW;
    data.k = k;
    data.combineRule = combineRule;
    out = trained_classifier(a, data);
    
% 测试部分
elseif mapping_task(argin,'execution')
    [a,v] = deal(argin{1:2}); 
	mapping = getdata(v);
    w = mapping.subW;
%     for i = 1:1:length(w)
%        W{i} = w{i} * dd_normc ;
%     end
    combineRule = mapping.combineRule;
    W_out = [w{:}] * combineRule;
    out = a * W_out;
     
end
end
