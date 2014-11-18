% E12论文使用的新方法
% 参数
%   A: 训练数据
%   nameClustAlgo: 聚类算法名
%   k: 聚类中心个数上限
%   frej: 拒绝率
function out = RSCH_OCL_ESM_ClustDBCVMST(varargin)
argin = setdefaults(varargin,[],'kmeans',6,0.1);

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['RSCH_DBCVMST' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [A ,nameClustAlgo,k,frej] = deal(argin{:});
    % 单独提取正类样本用于训练
    A_target = target_class(A);
    
    % 聚类分析
    dbcv = zeros(1,k);
    msts = cell(1,k);
    dbcv_best = -Inf;
    best_k = 0;
    for i = 2 : 1 : k
        % 调用聚类算法（先只使用kmeans测试）
        switch nameClustAlgo
            case 'kmeans'
                Idx = feval(nameClustAlgo,A_target,i);
                num_clust = length(unique(Idx));
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
                [Idx,type]=dbscan(+A_target,i,[]) ;
                num_clust = length(unique(Idx))-1; % -1 是outlier
        end
        
        if 1 == length(unique(Idx))
            disp 'k= 1'
            continue;
        end
        
        [dbcv(i),trees{i},adjM{i}] = MLAT_DBCV(A_target,Idx);  
        fprintf('k=%d时，DBCV评价：%.2f\n',i,dbcv(i));
        if dbcv(i) > dbcv_best
            dbcv_best = dbcv(i);
            best_k = num_clust;
            best_i = i;
            best_Idx = Idx;
        end
    end
    
    % 对每一个聚类簇的MST直接构建MST单类分类模型
    subW = cell(1,best_k);
    for i = 1:1:best_k
        subW{i}= RSCH_OCL_ESM_ClustDBCVMST_subMST(A_target,frej,trees{best_i}{i},adjM{best_i}{i});
    end
    
    % 构建trained的prmapping
    data.Idx = best_Idx;
    data.subW = subW;
    data.k = best_k;
    data.mst = trees{best_i};
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