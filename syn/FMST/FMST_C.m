% ����˵��
% a: ѵ�����ݼ�
% OCCAlgo: ��������������ʽ����ʹ��ֱ�ӵ��õĸ�ʽ
% combineRule: ���������ļ��ɷ���
%       -- mergec ��󻯾��߽߱缯��
function out = FMST_C(varargin)
argin = setdefaults(varargin,[],'gauss_dd',mergec);
if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['FMST' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [a,OCCAlgo,combineRule] = deal(argin{:}); 
    data.combinRule = combineRule;
    % ������ȡ������������ѵ��
     a_origin = a;
     a = target_class(a);
    % ��һ�ξ���
     n = length(a.data);
     k = floor(sqrt(n));
    %DAC Divide and Conquer Using K-means
    [Idx, C] = kmeans(a.data, k);
     % ��ÿһ����������ɵ������ģ��
    subW1 = cell(1,k);
    for i = 1:1:k
        thisClusterIdx = find(Idx==i);
        A = seldat(a, [],[], thisClusterIdx);
        subW1{i}= eval(strcat(OCCAlgo,'(A)'));
    end
    data.subW1 = subW1;
    %�ڶ��ξ���  
    dist_c = squareform( pdist(C, 'euclidean'));  
   [tree_c,]=mst(dist_c);
    for i = 1:length(tree_c)
       cluster(i,:) = (C(tree_c(i,1),:)+ C(tree_c(i,2),:))/2;
    end
   [IDX2, C2] = kmeans(a.data, k-1,'Start',cluster, 'Replicates',1);
    subW2 = cell(1,k-1);
    for i = 1:1:k
        thisClusterIdx = find(IDX2==i);
        A = seldat(a, [],[], thisClusterIdx);
        subW2{i}= eval(strcat(OCCAlgo,'(A)'));
    end
    data.subW2 = subW2;
    % ����trained��prmapping
    out = trained_classifier(a_origin, data);    
% ���Բ���
elseif mapping_task(argin,'execution')
    [a,v] = deal(argin{1:2}); 
    a = prdataset(a);
	mapping = getdata(v);   
%     w = [mapping.subW1,mapping.subW2];
    combineRule = mapping.combinRule;
    w = mapping.subW1;
    W_out = [w{:}] * combineRule;
    out = a * W_out; 
end
end