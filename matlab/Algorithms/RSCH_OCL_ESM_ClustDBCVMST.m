% E12����ʹ�õ��·���
% ����
%   A: ѵ������
%   nameClustAlgo: �����㷨��
%   k: �������ĸ�������
%   frej: �ܾ���
function out = RSCH_OCL_ESM_ClustDBCVMST(varargin)
argin = setdefaults(varargin,[],'kmeans',6,0.1);

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['RSCH_DBCVMST' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [A ,nameClustAlgo,k,frej] = deal(argin{:});
    % ������ȡ������������ѵ��
    A_target = target_class(A);
    
    % �������
    dbcv = zeros(1,k);
    msts = cell(1,k);
    dbcv_best = -Inf;
    best_k = 0;
    for i = 2 : 1 : k
        % ���þ����㷨����ֻʹ��kmeans���ԣ�
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
                num_clust = length(unique(Idx))-1; % -1 ��outlier
        end
        
        if 1 == length(unique(Idx))
            disp 'k= 1'
            continue;
        end
        
        [dbcv(i),trees{i},adjM{i}] = MLAT_DBCV(A_target,Idx);  
        fprintf('k=%dʱ��DBCV���ۣ�%.2f\n',i,dbcv(i));
        if dbcv(i) > dbcv_best
            dbcv_best = dbcv(i);
            best_k = num_clust;
            best_i = i;
            best_Idx = Idx;
        end
    end
    
    % ��ÿһ������ص�MSTֱ�ӹ���MST�������ģ��
    subW = cell(1,best_k);
    for i = 1:1:best_k
        subW{i}= RSCH_OCL_ESM_ClustDBCVMST_subMST(A_target,frej,trees{best_i}{i},adjM{best_i}{i});
    end
    
    % ����trained��prmapping
    data.Idx = best_Idx;
    data.subW = subW;
    data.k = best_k;
    data.mst = trees{best_i};
    out = trained_classifier(A_target, data);
    
% ���Բ���
elseif mapping_task(argin,'execution')
    [a,v] = deal(argin{1:2}); 
	mapping = getdata(v);
    w = mapping.subW;
    W_out = [w{:}] * mergec;
    out = a * W_out;
     
end
end