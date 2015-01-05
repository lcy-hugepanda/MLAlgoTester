% E12�㷨
% ���ڲ�ξ��ࡢDBCV���ۺ�DCT���Ľṹ������OCC
%
% ����˵��
% a: ѵ�����ݼ�
% k: ����������     
%alf:���Բ���ѡ��

function out = RSCH_OCL_ESM_ClustDBCVMST(varargin)
argin = setdefaults(varargin,[],5,0.1);
if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['MLAlgo_Ensemble_' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [a ,k,alf] = deal(argin{:});
    
    % ������ȡ������������ѵ��
    a_origin = a;
    a = target_class(a);
    % �������������ľ�����󣨾����㷨��Ҫ��
    disM = pdist(+a);
    
    % ��ξ���
%   ����ԭ���õ���PRTools��hclust�������������������֧����õ�ward����������
% 	dendg = hclust(disM,'average'); % dendrogram
% 	plotdg(dendg)
    % ʹ��ward�õ���ξ����������ص�clust��һ��(m-1)x3�ľ���m�������ĸ���
    % �����ÿһ�б�ʾ��һ�ξۺϣ��ۺϴ�1���ۺϴ�2���ۺ�ʱ����
    clust = linkage(disM,'ward');  
    
    % ȷ���������
    [core_point, core_point_idx,Idx,k,tree,apts,dmreach,fdata,fclusterIdx,fcompcl] = ...
        E12_DBCV(a, clust,k);
    
    fprintf('k = %d\n',k);
    
    mstdata.core_point = core_point;
    mstdata.core_point_idx = core_point_idx;
    mstdata.tree = tree;
    mstdata.apts = apts;
    mstdata.fdata = fdata;
    mstdata.dmreach = dmreach; 
    mstdata.Idx = Idx;
    mstdata.clusterIdx = fclusterIdx;
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
    Idx = mapping.mst.core_point_idx(min_idx); % Idx��ʾ���Լ��и����������ľ����
    
    d_reach = cell(a.objsize);
    for i = 1:a.objsize
%         dist = pdist2(a.data(mapping.mst.clusterIdx{Idx(i)},:),a.data(i,:),'Euclidean');
%         numerator = sum((1./dist(find(dist>0))) .^ a.featsize);
%         %���ӳ�ni-1���-1/d���ݡ�
%         apts(i) = (numerator/length(mapping.mst.clusterIdx{Idx(i)})) ^(-1/a.featsize);
%         %aptsΪ���Լ���ÿ�����aptֵ��mapping.mst.aptsΪѵ�����е��aptֵ��
%         for j = 1:1:length(mapping.mst.clusterIdx{Idx(i)})
% %             d_reach{i}(j) = min([apts(i) mapping.mst.apts(mapping.mst.clusterIdx{Idx(i)}(j)) dist(j)]);
%             d_reach{i}(j) = max([apts(i) min(dist)]);
%         end        
        
        % ��ʹ�ø�����ص�core�����ɴ����
        data_core = [mapping.mst.core_point(find(mapping.mst.core_point_idx == Idx(i)),:); a.data(i,:)];
        dist_core = pdist(data_core,'Euclidean');
        for i = 1 : 1 : size(data_core,1)
            numerator = sum((1./dist_core(find(dist_core > 0))) .^ a.featsize);
            %���ӳ�ni-1���-1/d���ݡ�
            apts(i) = (numerator/length(find(mapping.mst.core_point_idx == Idx(i)))) ^(-1/a.featsize);
        end

        %aptsΪ���Լ���ÿ�����aptֵ��mapping.mst.aptsΪѵ�����е��aptֵ��
        for j = 1:1:length(find(mapping.mst.core_point_idx == Idx(i)))
%             d_reach{i}(j) = max([apts(i) mapping.mst.apts(mapping.mst.clusterIdx{Idx(i)}(j)) dist(j)]);
            d_reach{i}(j) = max([apts(i) min(mapping.mst.apts(find(mapping.mst.clusterIdx==i)))  min(dist_core(j))]);
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

    out = setdat(a,result,v);     
end
end


function [core_point, core_point_idx, Index,k,tree,fapts,freach,fdata,fclusterIdx,fcompcl] = E12_DBCV(a, clust,k)
    is_found_k = 0;
    for i = 2:k 
        Idx{i} = cluster(clust,'maxclust',i);
        [dbcv(i),ftree{i},apts{i},dmreach{i},data{i},clusterIdx{i},compcl{i},point_degree{i}]...
            = DBCV(a.data,Idx{i},'normal');
    end
    if ~is_found_k
        [~,i] = max(dbcv(2:end));
        best_k = i + 1;
    end
    
    % ����ԭ�����߼��Ǵ洢k-centers�ľ������ģ����������������˾����㷨����̫����
%     for j = 1:i
%         centers(j,:) = a.data(center{i}(j),:);
%     end
    % �µ��߼�����ÿһ���������core��Ϊ������ȷ���������������ľ����
    dataM = getdata(a);
    core_point = []; % ÿһ������Ԫ�أ���һ���Ǿ���ر�ţ��ڶ����Ǿ�����и������ı��
    core_point_idx = [];
    degree = point_degree{best_k};
    for i = 1 : 1 : best_k % ����ÿһ�������
        idx_this_clusterIdx = clusterIdx{best_k}{i}; % �þ�����������ı��  
        for j = 1 : 1 : length(idx_this_clusterIdx)  % ���ھ������ÿһ����
            if degree{i}(j) > 2   % ��֮�����ĵ㳬��3��������core��                     
                core_point  = [core_point;data{best_k}{i}(j,:)];
                core_point_idx = [core_point_idx; i];
            end
        end
    end
        
    Index = Idx{best_k};
    k = best_k;
    tree = ftree{best_k};
    fdata = data{best_k};
    fapts = apts{best_k};
    freach = dmreach{best_k};
    fclusterIdx = clusterIdx{best_k};
    fcompcl = compcl{best_k};
end