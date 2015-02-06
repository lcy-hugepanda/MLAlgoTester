% E10���õ��Ļ��㷨
% ʹ��DBCV�е�DCT����������������DCT���OCC����
% ����
%   A: ѵ������(�����飬������)
%   tree��DCT����m x 3����ÿһ����һ���ߣ�[���A ���B �߳�]
%   apts: ����������core distance
%   compcl�����������ɴ����
%   point_degree:��������������degree
%   
%   
function out = RSCH_OCL_SIGL_DCTDD(varargin)
argin = setdefaults(varargin,[],0.05,[],[],0,[]);

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['DCT_DD_' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [A ,rejf, tree,apts, compcl, point_degree] = deal(argin{:});
    
    % ������ֵ
	int_node     = find(point_degree~=1);
    int_edg1     = find(ismember(tree(:,1),int_node));    
    int_edg2     = find(ismember(tree(:,2),int_node));    
    int_edges = intersect(int_edg1,int_edg2);
    thr = sort(tree(int_edges,3),'descend');
    thr = thr(fix(length(thr)*(1-rejf))+1);
%     thr = thr(fix(length(thr)*0.5));

    % ����trained��prmapping
    data.tree = tree;
    data.apts = apts;
    data.compcl = compcl;
    data.A = A;
    data.thr = thr;
    data.point_degree = point_degree;
    
    dummy_label = ones(size(A,1),1);
    dummy_label(1) = 2;
    out = trained_classifier(prdataset(A, dummy_label), data);

% ���Բ���
elseif mapping_task(argin,'execution')
    [A,v] = deal(argin{1:2}); 
	mapping = getdata(v);

    A_train = mapping.A;
    d = size(A,2);
    distM_core = pdist2(+A, A_train(find(mapping.point_degree > 3),:));
    distM = pdist2(+A, A_train);
    
    res = zeros(size(A,1),2);
    for i = 1 : 1 : size(A,1) % ����ÿһ����������
        distV = sort(distM_core(i,:)); % ��������������target�����ľ��루��С��������
        
        core_dist = ((sum((1./distV).^d))./(size(A_train,1))).^(-1/d);
        core_dist = max([core_dist  min(distM_core(i,:))]);
%         res(i,1) = core_dist - mapping.compcl;
%         res(i,1) = mapping.compcl - core_dist;
        res(i,1) = core_dist - mapping.thr/2;
    end
    
    out = setdat(A,res,v); 
end
end