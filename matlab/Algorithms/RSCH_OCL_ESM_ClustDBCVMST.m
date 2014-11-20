% ����˵��
% a: ѵ�����ݼ�
% k: ����������     
% numClustAlgo: �����㷨����
%       -- kmeans
%       -- enclust
%       -- hclust
%       -- modeseek
%       -- kcenters
%       -- fcm
%       -- dbscan
%alf:���Բ���ѡ��

function out = RSCH_OCL_ESM_ClustDBCVMST(varargin)
argin = setdefaults(varargin,[],3,'kcentres',0.1);
if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['MLAlgo_Ensemble_' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [a ,k,nameClustAlgo,alf] = deal(argin{:});
    % ������ȡ������������ѵ��
    a_origin = a;
    a = target_class(a);
    % �������������ľ�����󣨾����㷨��Ҫ��
    disM = sqrt(distm(a));
    % ȷ���������
    [centers, Idx,k,tree,apts,dmreach,fdata,fcluster,fcompcl] = selectKbyDBCV(a, disM, nameClustAlgo,k);
    mstdata.center = centers;
    mstdata.tree = tree;
    mstdata.apts = apts;
    mstdata.fdata = fdata;
    mstdata.dmreach = dmreach; 
    mstdata.Idx = Idx;
    mstdata.cluster = fcluster;
    mstdata.compcl = fcompcl;
    % ����trained��prmapping
    data.Idx = Idx;
    data.k = k;
    data.mst = mstdata;
    data.alf = alf;
    out = trained_classifier(a_origin, data);    
% ���Բ���
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
        %���ӳ�ni-1���-1/d���ݡ�
        apts(i) = (numerator/length(mapping.mst.fdata{Idx(i)})) ^(-1/a.featsize);
        %aptsΪ���Լ���ÿ�����aptֵ��mapping.mst.aptsΪѵ�����е��aptֵ��
        for j = 1:length(mapping.mst.fdata{Idx(i)})
            d_reach{i}(j) = max([apts(i) mapping.mst.apts(mapping.mst.cluster{Idx(i)}(j)) dist(j)]);
        end
    end
    %d_reachΪ���Լ��е㵽�þ���ص�Ŀɴ���롣

    % �趨ÿһ������ص��ж���ֵ
    thr = zeros(1,mapping.k);
    for i = 1 : 1 : mapping.k
%             mst_path = mapping.mst.path{i};
%             thr(i) = max(max(mst_path)) * (1 - 0.1);
%���thr
        mst_path = mapping.mst.tree{i}(:,3);
        thr(i) = max(mst_path) * (1 - 0.1);
%ȥ��1����thr
%        thr(i) = mapping.mst.compcl(i) * (1 - mapping.alf);
    end

    % ������ֵ�ж����Ե�Ĺ���
    result = zeros(a.objsize, 2);
    for i = 1 : 1 : a.objsize
        result(i,1) = min(d_reach{i}) - thr(Idx(i));
    end

    out = setdat(a,result,v);     
end
end
