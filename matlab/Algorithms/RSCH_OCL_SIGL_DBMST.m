% һ��ʵ�鷽��
% ����ͨ��������DBCV�ķ�ʽ�����ܶȷ������õ���������ص���С������
% ֮���ÿһ��MST���зֽⲢʹ��gauss_dd����
% ���ʹ��mergec�ϲ�
% ����
%   A: ѵ������
%   nameClustAlgo: �����㷨��
%   k: �����㷨�Ĳ���
%   frej: �ܾ���
function out = RSCH_OCL_SIGL_DBMST(varargin)
argin = setdefaults(varargin,[],0.1);

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['RSCH_DBCVMST' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [A ,frej] = deal(argin{:});
    % ������ȡ������������ѵ��
    A_target = target_class(A);
    num_target = size(A_target,1);
    
    % �������
%     switch nameClustAlgo
%         case 'dbscan'
%                 [Idx,type]=dbscan(+A_target,k,[]) ;
%                 num_clust = length(unique(Idx))-1; % -1 ��outlier
%         case 'kmeans'
%                 Idx = kmeans(A_target,k);
%                 num_clust = length(unique(Idx));
%     end
            
    Idx = ones(size(A_target,1),1);
    [~,trees,adjM] = MLAT_DBCV(A_target,Idx);
    
    % ɾ��̫���ıߣ�����������ܾ���frej���� (��ǰ������adjM��ɾ��)
    num_delete = fix(num_target * frej*2);
    pruned_adjM = adjM{1};
    while num_delete > 0
        [temp, del_x] = max(pruned_adjM);
        [temp, del_y] = max(temp);
        pruned_adjM(del_x(del_y),del_y) = 0;
        %fprintf('prun: %d %d\n',del_x(del_y),del_y);
        num_delete = num_delete - 1;
    end
    
    % �����з����õ�core point
    % ͬʱ��core pointΪ���Ĺ���ÿһ��core set
    point_weight = zeros(1, num_target);
    idx_core = [];
    core_set = cell(0);
    for i = 1 : 1 : num_target  % ����ÿһ����
        point_set = find(pruned_adjM(i,:)>0); % ��ȡ��֮�����ĵ㼯
        point_weight(i) = length(point_set);
        if point_weight(i) > 2   % ��֮�����ĵ㳬��1��������core��
            idx_core = [idx_core; i];
            core_set = [core_set; point_set];   % ��core�������ľ���core��
        end
    end
   
    % ��ÿһ��core�������������ģ�ͣ��ⲿ����Ҫϸ����
    subW = cell(1,length(core_set));
    for i = 1:1:length(core_set)
        A_target_thisCore = seldat(A_target,[],[],core_set{i});
        subW{i}= gauss_dd(A_target_thisCore,frej);
    end
    
    % ����trained��prmapping
    data.Idx = Idx;
    data.Idx_core = idx_core;
    data.subW = subW;
    data.k = length(core_set);
    data.mst = trees;
    data.adjM = pruned_adjM;
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