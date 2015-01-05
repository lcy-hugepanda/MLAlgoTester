% һ��ʵ�鷽�� E-10
% ����ͨ��������DBCV�ķ�ʽ�����ܶȷ������õ���������ص���С������
% ֮���ÿһ��MST���зֽⲢʹ��gauss_dd����
% ���ʹ��mergec�ϲ�
% ����
%   A: ѵ������
%   nameClustAlgo: �����㷨��
%   k: �����㷨�Ĳ���
%   frej: �ܾ���
function out = RSCH_OCL_SIGL_DBMEOC(varargin)
argin = setdefaults(varargin,[],0.1,0.01,false,0.1);

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['RSCH_E10_DBM-EOC' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [A ,frej,delete_thr,is_merge_core, para_gauss] = deal(argin{:});
    % ������һЩ΢��ѡ��
    knn_para = 1; % Խ��Ļ�������KNN�ĵ�Խ�٣�ȡ1��ʱ������е�ȡKNN
    is_delete_edge = true; % �Ƿ����DCT���ĳ��ȷֲ�ɾ�����ڳ��ı�
%     delete_para = 5; % Խ��Ļ�ɾ���ı�Խ�٣�Ĭ��ȡ5
%     delete_thr = 0.015; % Z����ɾ�����ߵ���������
%     is_merge_core = false; % �Ƿ񽫹���С��core���ϲ������core����
%     para_gauss = 0.1;
    
    % ������ȡ������������ѵ��
    A_target = target_class(A);
    [num_target,d] = size(A_target);

    % �ܶȷ���
    index = ones(size(A_target,1),1);
    dataM = +A_target;
    
    % ����ÿһ��������APT
    o = 1;
    %�õ��������
    distM =  squareform( pdist(dataM, 'euclidean'));  
    for j = 1:num_target
        %���ӣ������j�⣬��j���������е���뵹��d����,������
        this_point_dist = sort(distM(j,:));
        knn_point_dist = this_point_dist(2:fix(length(this_point_dist)/knn_para));
        numerator = sum((1./knn_point_dist).^ 2);
        %���ӳ�ni-1���-1/d���ݡ�
        apts(o) =  (numerator/ (num_target - 1)) ^(-1/ 2) ;
        o = o + 1;
    end
     
    %����ɴ����
    for i = 1:1:num_target
        for j = 1:1:num_target
            d_mreach(i,j) = max([ min([apts(i) apts(j)]) distM(i,j)]); 
%             d_mreach(i,j) = max([apts(i) apts(j) distM(i,j)]);
%             d_mreach(i,j) = max([apts(i) apts(j)]);
%             d_mreach(i,j) = distM(i,j);
        end
    end
    %conducting an MST
    [trees,adjM]=mst(d_mreach);
    
    % ɾ��̫���ı� (��ǰ������adjM��ɾ��)
    % ʵ����ʾ��ĳЩ���ݼ��ϣ���ȫ��ɾ����Ч�����ܸ���һ��
    % �������Ĵ�����Ҫ������һЩ�����ǲ���MST_CD�ķ�ʽ
    pruned_adjM = adjM;
    length_edge = pruned_adjM(find(pruned_adjM>0));
    
    % Z-test��pruning�߼�
    outlier = [];
    for i = 1 : 1 : length(length_edge)
        z = ztest(length_edge(i),mean(length_edge),std(length_edge),delete_thr);
        if 1 == z
            outlier = [outlier length_edge(i)];
        end
    end

%     ����ע�͵�����һ�ּ򵥴ֱ���pruning���ⲿ��ֻ��Ҫ�ó�һ����������
%     length_edge = sort(length_edge);
%     k1 = 1;
%     k2 = 1;
%     inlier = [];
%     outlier = [];
%     len = length(length_edge);
%     average1 = mean(length_edge);
%     standard1 = std(length_edge);
%     for i = 1:len
%         if abs( length_edge(i) - average1) < k1 * standard1
%             inlier = [inlier length_edge(i)];
%         end
%     end
%     average2 = mean(inlier);
%     standard2 = std(inlier);
%     for i = 1:len
%         if length_edge(i) - average2 >= k2 * standard2 * delete_para %���ﲻȡ����ֵ����Ϊ����ֻ����̫���ı�
%             outlier = [outlier length_edge(i)];
%         end
%     end
    
    num_delete = length(outlier);
    fprintf('%d egdes deleted . \n',num_delete);
    
    % ����֮ǰ���߼������մӴ�С��˳��ɾ���������ߣ�����������frej
    %num_delete = fix(num_target * frej * 2);
    if ~is_delete_edge
        num_delete = 0;
    end
    pruned_adjM = adjM;
    pruned_trees = trees;
    deleted_edges = [];
    while num_delete > 0
        [temp, del_x] = max(pruned_adjM);
        [temp, del_y] = max(temp);
        pruned_adjM(del_x(del_y),del_y) = 0;
        
         fprintf('prun: %d %d\n',del_x(del_y),del_y);
        % �ⲿ������MNIST�ҳ�outlierͼƬ
%         fprintf('prun: %f %f\n',dataM(del_x(del_y),1),dataM(del_x(del_y),2));
%         fprintf('prun: %f %f\n',dataM(del_y,1),dataM(del_y,2));

        num_delete = num_delete - 1;
        
        
        % ͬʱ��Ҫ�ó�һ��pruned֮���tree
        for i = 1 : 1 : size(pruned_trees,1)
            if pruned_trees(i,1) == del_x(del_y) && pruned_trees(i,2) == del_y
                pruned_trees(i,:) = [0 0];
                deleted_edges = [deleted_edges ;trees(i,:)];
            end
        end
    end
    
    % �����з����õ�core point
    % ͬʱ��core pointΪ���Ĺ���ÿһ��core set
    point_weight = zeros(1, num_target);
    idx_core = [];
    core_set = cell(0);
    for i = 1 : 1 : num_target  % ����ÿһ����
        point_set = find(pruned_adjM(i,:)>0); % ��ȡ��֮�����ĵ㼯
        point_weight(i) = length(point_set);
        if point_weight(i) > 1   % ��֮�����ĵ㳬��1��������core��
            % ʵ���ԣ����core����̫�٣������ߵĵ�����չ
%             if point_weight(i) < 5
%                 for j = 1 : 1 : point_weight(i)
%                     addon_point_set = intersect(...
%                         find(pruned_adjM(point_set(j),:)>0),...
%                         find(pruned_adjM(point_set(j),:)<50*pruned_adjM(i,point_set(j))));
%                     addon_point_set(find(addon_point_set == i)) = [];
%                     point_set = [point_set addon_point_set];
%                 end
%             end                      
            idx_core = [idx_core; i];
            core_set = [core_set; point_set];   % ��core�������ľ���core��
        end
    end
    
    if is_merge_core
        % ʵ���ԣ����core���������ϲ�core��
        for i = 1 : 1 : length(idx_core) % ���ÿһ��core�㣬���Կ��ǲ��ǻ���������core��
            appeared_core_set = [];
            for j = 1 : 1 : length(core_set) % Ѱ��core�����ڵ�core��
                appeared_core_set = [appeared_core_set j];
            end
            if length(appeared_core_set)>1
                new_core_set = [];
                for j = 1 : 1 : length(appeared_core_set) % ������Щcore_set
                    if length(core_set{appeared_core_set(j)}) < 4
                        new_core_set = [new_core_set core_set{appeared_core_set(j)}];
                        core_set{appeared_core_set(j)} = [];
                    end
                end
                core_set{appeared_core_set(1)} = unique(new_core_set);
            end
        end
    end
    
    % ��ÿһ��core�������������ģ�ͣ��ⲿ����Ҫϸ����
%     subW = cell(1,length(core_set));  
    subW = cell(0);
    w_idx = 1;
    for i = 1:1:length(core_set)
        if isempty(core_set{i})
            continue;
        end
        A_target_thisCore = seldat(A_target,[],[],core_set{i});
        if 2 == size(A_target_thisCore,1)
            dataM = +A_target_thisCore;
            if 0 == sum(dataM(1,:)-dataM(2,:))
                continue;
            end
        end
        if 3 == size(A_target_thisCore,1)
            dataM = +A_target_thisCore;
            if 0 == sum(dataM(1,:)-dataM(2,:))
                if 0 == sum(dataM(2,:)-dataM(3,:))
                    continue;
                end
            end
        end
        if size(A_target_thisCore,1) > 1
            subW{w_idx}= gauss_dd(A_target_thisCore,frej,para_gauss);
%             subW{w_idx}= parzen_dd(A_target_thisCore,frej);
%             subW{w_idx}=OCLT_AlgoLibsvmOCSVM(A_target_thisCore, 'default', frej, A_target_thisCore);
            % subW{w_idx}=incsvdd(A_target_thisCore, frej,1.0/d);
            w_idx = w_idx +1 ;
        end
    end
    
    % ����trained��prmapping
    data.Idx_core = idx_core;
    data.subW = subW;
    data.k = length(subW);
    data.mst = trees;
    data.mst_pruned = pruned_trees;
    data.deleted_edges = deleted_edges;
    data.adjM = pruned_adjM;
    data.core_set = core_set;
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