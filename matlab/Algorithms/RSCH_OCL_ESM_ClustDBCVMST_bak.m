% ����һ�������ļ�����������E12�㷨��һ�����ڰ汾
% �ð汾���Խ��ܸ��־����㷨��Ȼ����DBCV��Kֵѡ��
% �������ڴ��������Ļ��������Խϲ�����ʱ����

% E12���ĵ�ʵ�����㷨
%
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
    
    % ȷ��ÿһ���������������ľ����
    % ԭ�����߼��Ǽ��������͸����������ĵ�ľ���
%     dist =  pdist2(a.data,mapping.mst.center,'Euclidean');
%     [mmin,Idx] = min(dist,[],2);
    % ������Ҫ�ĳ���core��֮��ľ���
    dist = pdist2(a.data,mapping.mst.core_point,'Euclidean');
    [~,min_idx] = min(dist,[],2);
    Idx = mapping.mst.core_point_idx(min_idx);
    
    d_reach = cell(a.objsize);
    for i = 1:a.objsize
        dist = [];
%         dist = pdist2(mapping.mst.fdata{Idx(i)},a.data(i,:),'Euclidean');
        dist = pdist2(mapping.mst.core_point(find(mapping.mst.core_point_idx == Idx(i)),:),a.data(i,:),'Euclidean');
        numerator = sum((1./dist(find(dist ~= 0))) .^ a.featsize);
        %���ӳ�ni-1���-1/d���ݡ�
        apts(i) = (numerator/length(mapping.mst.fdata{Idx(i)})) ^(-1/a.featsize);
        %aptsΪ���Լ���ÿ�����aptֵ��mapping.mst.aptsΪѵ�����е��aptֵ��
        for j = 1:1:length(mapping.mst.core_point(find(mapping.mst.core_point_idx == Idx(i)),:))
            d_reach{i}(j) = max([apts(i) mapping.mst.apts(mapping.mst.cluster{Idx(i)}(j)) dist(j)]);
%             d_reach{i}(j) = max([apts(i) mapping.mst.apts(mapping.mst.cluster{Idx(i)}(j))]);
%             d_reach{i}(j) = apts(i);
        end
    end
    %d_reachΪ���Լ��е㵽�þ���ص�Ŀɴ���롣

    % �趨ÿһ������ص��ж���ֵ
    thr = zeros(1,mapping.k);
    for i = 1 : 1 : mapping.k
%             mst_path = mapping.mst.path{i};
%             thr(i) = max(max(mst_path)) * (1 - 0.1);
%������ֵȥ�������ߵ����thr
        mst_path = sort(mapping.mst.tree{i}(:,3));
        thr_2 = max(mst_path(1:fix(length(mst_path)*(1-mapping.alf))));
%���thr
        mst_path = mapping.mst.tree{i}(:,3);
        thr_3 = max(mst_path);
%ƽ���߳�thr
        mst_path = mapping.mst.tree{i}(:,3);
        thr_4 = mean(mst_path);
%ȥ��1����thr
        thr_5 = mapping.mst.compcl(i) * (1 - mapping.alf);

        thr(i) = thr_3;
    end

    % ������ֵ�ж����Ե�Ĺ���
    result = zeros(a.objsize, 2);
    for i = 1 : 1 : a.objsize % ����ÿһ������
        result(i,1) = min(d_reach{i}) - thr(Idx(i));
    end
    
    %sm = sum(result,2);
    %result = result./repmat(sm,1,2);
    
    % ����һ�����ƣ�������ϱ��������Ŷ~
    % ����ľ���˰�������ϱ��������������
    % ���ϱ�����ˣ���ҧ�ң�
    % ��ϧ���Ǹ����ư�����������ϱ������Ҫ���ˡ������������ء�����
    
    %result = 1 - result;
    out = setdat(a,result,v);     
end
end
