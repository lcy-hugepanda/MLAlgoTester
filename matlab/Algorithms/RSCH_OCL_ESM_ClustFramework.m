% ����˵��
% a: ѵ�����ݼ�
% numClust: ���ȷ���������
%       --'direct'   ��ֱ�Ӹ����������
%       --'entropy' ������ȷ���������
% k: �������
%       -- ���numClust��'direct'����k��������ľ������
%       -- ���numClust�������Զ�ȷ����������ķ�������k���������������
%       -- ��������㷨����Ҫָ�������������k�Ǹþ����㷨�ı������������DBSCAN��
% numClustAlgo: �����㷨����
%       -- kmeans
%       -- enclust
%       -- hclust
%       -- modeseek
%       -- kcenters
%       -- fcm
%       -- dbscan
% OCCAlgo: ��������������ʽ����ʹ��ֱ�ӵ��õĸ�ʽ
% combineRule: ���������ļ��ɷ���
%       -- maxc ��󻯾��߽߱缯��

function out = RSCH_OCL_ESM_ClustFramework(varargin)
argin = setdefaults(varargin,[],3,'kmeans','svdd',maxc);
if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['MLAlgo_Ensemble_' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [a ,numClust,k ,nameClustAlgo,OCCAlgo,combineRule] = deal(argin{:});
    % ������ȡ������������ѵ��
    a = target_class(a);
    % �������������ľ�����󣨾����㷨��Ҫ��
    disM = sqrt(distm(a));
        
    % ȷ���������
    if strcmp(numClust,'direct')
        ; % ֱ��ʹ�ò���k
    end
    
    % ���þ����㷨,�������������k����������ȫ������Ĭ��ֵ���滻��λ
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
    
    
    % ��ÿһ����������ɵ������ģ��
    subW = cell(1,k);
    for i = 1:1:k
        thisClusterIdx = find(Idx==i);
        A = seldat(a, [],[], thisClusterIdx);
        subW{i}= eval(OCCAlgo);
    end
    
    % ����trained��prmapping
    data.Idx = Idx;
    data.subW = subW;
    data.k = k;
    data.combineRule = combineRule;
    out = trained_classifier(a, data);
    
% ���Բ���
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
