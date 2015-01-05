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
        % 在DBCV中，如果聚类簇只有一个样本，则会被认为是noise而去除
        % 如果总聚类数只有2个，那么这种情况会报错（DBCV无法处理聚类簇为1的情况）
        % 于是，这里做一个处理，如果聚类簇个数少于阈值并且有一个聚类簇中只有一个样本，则不进行DBCV选择
        % 直接认为是单模分布
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
            % 一般情况，计算DBCV
            [dbcv(i),ftree{i},apts{i},dmreach{i},data{i},cluster{i},compcl{i},point_degree{i}]...
                = DBCV(a.data,Idx{i},'normal');
        end
    end
    if ~is_found_k
        [~,i] = max(dbcv(2:end));
        best_k = i + 1;
    end
    
    % 这里原来的逻辑是存储k-centers的聚类中心，但是这样就限制了聚类算法，不太合适
%     for j = 1:i
%         centers(j,:) = a.data(center{i}(j),:);
%     end
    % 新的逻辑，以每一个聚类簇中core点为线索，确定后续样本所属的聚类簇
    dataM = getdata(a);
    core_point = []; % 每一行两个元素，第一个是聚类簇标号，第二个是聚类簇中该样本的标号
    core_point_idx = [];
    degree = point_degree{best_k};
    for i = 1 : 1 : best_k % 对于每一个聚类簇
        idx_this_cluster = cluster{best_k}{i}; % 该聚类簇中样本的标号  
        for j = 1 : 1 : length(idx_this_cluster)  % 对于聚类簇中每一个点
            if degree{i}(j) > 2   % 与之相连的点超过3个，就是core点                     
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