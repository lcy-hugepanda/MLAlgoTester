function [core_point, core_point_idx, Index,k,tree,fapts,freach,fdata,fcluster,fcompcl] = selectKbyDBCV(a, disM, nameClustAlgo,k)
    is_found_k = 0;
    for i = 2:k
         switch nameClustAlgo
            case 'kmeans'
                Idx{i} = feval(nameClustAlgo,a,i);

            case 'emclust'
                Idx{i} = feval(nameClustAlgo,a,[],i,[]);
            case 'hclust'            
                Idx{i} = feval(nameClustAlgo,disM,'single',i);
            case 'modeseek'
                Idx{i} = feval(nameClustAlgo,disM,i);
            case 'kcentres'
                [Idx{i} center{i} DM{i}] = feval(nameClustAlgo,disM,i);
            case 'fcm'
                [center11,U,obj_fcn] = fcm(a.data,i);
                maxU = max(U);
                Idx{i} = zeros(length(a.data),1);
                for ii = 1:k  
                    Idx{i}(find(U(ii,:) == maxU)) = ii;
                end 
            case 'dbscan'
                [Idx{i},type]=dbscan(a.data,i,[]) ;
                i = max(unique(Idx{i}));
         end
    %      [dbcv(i),ftree{i},A{i},data{i},apts{i},dmreach{i}] = MLAT_DBCV(a,Idx{i});
        % ��DBCV�У���������ֻ��һ����������ᱻ��Ϊ��noise��ȥ��
        % ����ܾ�����ֻ��2������ô��������ᱨ��DBCV�޷���������Ϊ1�������
        % ���ǣ�������һ�������������ظ���������ֵ������һ���������ֻ��һ���������򲻽���DBCVѡ��
        % ֱ����Ϊ�ǵ�ģ�ֲ�
        thr = 0.05 * getsize(a,1);
        if 2 == i && (thr > length(find(Idx{2}==1)) || thr > length(find(Idx{2}==2)))
            is_found_k = 1;
            best_k = 1;
            Idx{1} = Idx{2};
            Idx{1}(:) = 1;
            i = 1;
            [dbcv(i),ftree{i},apts{i},dmreach{i},data{i},cluster{i},compcl{i},point_degree{i}]...
                = DBCV(a.data,Idx{i},'single');
            break;
        else
            % һ�����������DBCV
            [dbcv(i),ftree{i},apts{i},dmreach{i},data{i},cluster{i},compcl{i},point_degree{i}]...
                = DBCV(a.data,Idx{i},'normal');
        end
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
        idx_this_cluster = cluster{best_k}{i}; % �þ�����������ı��  
        for j = 1 : 1 : length(idx_this_cluster)  % ���ھ������ÿһ����
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
    fcluster = cluster{best_k};
    fcompcl = compcl{best_k};
end